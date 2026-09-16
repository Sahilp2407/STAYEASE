import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hotel_models.dart';
import '../data/hotel_data.dart';
import 'firestore_service.dart';

// ── APP STATE: पूरे ऐप का ग्लोबल स्टेट, यूजर सेशन और डेटा सिंक मैनेज करने के लिए ──
class AppState extends ChangeNotifier {
  // पूरे ऐप में शेयर होने वाला सिंगल इंस्टेंस
  static final AppState instance = AppState._internal();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;

  AppState._internal() {
    // डेमो के लिए इनिशियल पास्ट बुकिंग डेटा
    _bookings.add(
      Booking(
        id: '#STY819230',
        hotel: kSampleHotels[1], // Udaivilas
        room: kSampleHotels[1].rooms.first,
        checkIn: DateTime.now().subtract(const Duration(days: 30)),
        checkOut: DateTime.now().subtract(const Duration(days: 28)),
        nights: 2,
        adults: 2,
        roomsCount: 1,
        guestName: 'Sahil Pandey',
        guestEmail: 'sahil@stayease.com',
        guestPhone: '+91 98200 12345',
        specialRequests: 'High floor, quiet suite',
        roomTotal: 33000,
        taxes: 5940,
        serviceFee: 500,
        totalAmount: 39440,
        status: BookingStatus.completed,
        paymentMethod: 'Credit Card (••4242)',
        bookedAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    );

    // Firebase Auth aur Firestore sync शुरू करना
    _initFirebaseSync();
  }

  // Firebase Auth स्टेट और Firestore फेवरिट्स को रियल-टाइम सिंक करना
  void _initFirebaseSync() {
    try {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          // यूजर लॉगिन होने पर लोकल स्टेट अपडेट करना
          _isLoggedIn = true;
          _currentUid = user.uid;
          _userName = user.displayName?.isNotEmpty == true
              ? user.displayName!
              : (_userName.isNotEmpty ? _userName : 'StayEase Guest');
          _userEmail = user.email?.isNotEmpty == true
              ? user.email!
              : (_userEmail.isNotEmpty ? _userEmail : '');
          _userPhone = user.phoneNumber?.isNotEmpty == true
              ? user.phoneNumber!
              : (_userPhone.isNotEmpty ? _userPhone : '+91 98200 12345');

          // Firestore से यूजर के सेव्ड फेवरिट्स सिंक करना
          _favoritesSubscription?.cancel();
          _favoritesSubscription = FirestoreService.instance
              .streamUserFavorites(user.uid)
              .listen((remoteFavs) {
            if (remoteFavs.isNotEmpty) {
              _favoriteIds.addAll(remoteFavs);
              notifyListeners();
            }
          });
        } else {
          // यूजर लॉगआउट होने पर स्टेट रीसेट करना
          _isLoggedIn = false;
          _currentUid = '';
          _favoritesSubscription?.cancel();
        }
        notifyListeners();
      });
    } catch (_) {
      // Firebase इनिशियलाइज न होने पर एरर हैंडलिंग
    }
  }

  // यूजर लॉगिन स्टेटस और प्रोफाइल फील्ड्स
  bool _isLoggedIn = false;
  String _currentUid = '';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  // यूजर स्टेटस और प्रोफाइल गेटर्स
  bool get isLoggedIn => _isLoggedIn;
  String get currentUid => _currentUid;
  String get userName => _userName.isNotEmpty ? _userName : 'Sahil Pandey';
  String get userEmail => _userEmail.isNotEmpty ? _userEmail : 'sahil@stayease.com';
  String get userPhone => _userPhone.isNotEmpty ? _userPhone : '+91 98200 12345';

  // फेवरिट होटल आईडीज का सेट
  final Set<String> _favoriteIds = {'hotel-01'};
  Set<String> get favoriteIds => _favoriteIds;
  Set<String> get favoriteHotelIds => _favoriteIds;

  // यूजर की सभी बुकिंग्स की लिस्ट
  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  // चेक करना कि होटल फेवरिट लिस्ट में है या नहीं
  bool isFavorite(String hotelId) => _favoriteIds.contains(hotelId);

  // होटल को फेवरिट्स में ऐड या रिमूव करना और Firestore में सिंक करना
  void toggleFavorite(String hotelId) {
    final isFav = _favoriteIds.contains(hotelId);
    if (isFav) {
      _favoriteIds.remove(hotelId);
    } else {
      _favoriteIds.add(hotelId);
    }
    notifyListeners();

    // लॉगिन होने पर Firestore में फेवरिट सिंक करना
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (isFav) {
        FirestoreService.instance.removeFavorite(
          uid: user.uid,
          hotelId: hotelId,
        );
      } else {
        final hotel = kSampleHotels.firstWhere(
          (h) => h.id == hotelId,
          orElse: () => kSampleHotels.first,
        );
        FirestoreService.instance.addFavorite(
          uid: user.uid,
          hotel: hotel,
        );
      }
    }
  }

  // मैन्युअल लॉगिन सेट करना (गेस्ट/ऑफलाइन मोड के लिए)
  void login({String? name, String? email, String? phone}) {
    _isLoggedIn = true;
    _userName = name ?? 'Sahil Pandey';
    _userEmail = email ?? 'sahil@stayease.com';
    _userPhone = phone ?? '+91 98200 12345';
    notifyListeners();
  }

  // लोकल स्टेट से यूजर सेशन लॉगआउट करना
  void logout() {
    _isLoggedIn = false;
    _currentUid = '';
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _favoritesSubscription?.cancel();
    notifyListeners();
  }

  // नई होटल बुकिंग लोकल लिस्ट और Firestore दोनों में जोड़ना
  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();

    // लॉगिन होने पर Firestore में बुकिंग सेव करना
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService.instance.saveBooking(
        uid: user.uid,
        booking: booking,
      );
    }
  }

  // बुकिंग कैंसिल करना और Firestore में स्टेटस अपडेट करना
  void cancelBooking(String bookingId) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final old = _bookings[idx];
      _bookings[idx] = Booking(
        id: old.id,
        userId: old.userId,
        hotel: old.hotel,
        room: old.room,
        checkIn: old.checkIn,
        checkOut: old.checkOut,
        nights: old.nights,
        adults: old.adults,
        roomsCount: old.roomsCount,
        guestName: old.guestName,
        guestEmail: old.guestEmail,
        guestPhone: old.guestPhone,
        specialRequests: old.specialRequests,
        roomTotal: old.roomTotal,
        taxes: old.taxes,
        serviceFee: old.serviceFee,
        totalAmount: old.totalAmount,
        status: BookingStatus.cancelled,
        paymentMethod: old.paymentMethod,
        bookedAt: old.bookedAt,
      );
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirestoreService.instance.cancelBooking(
          uid: user.uid,
          bookingId: bookingId,
        );
      }
    }
  }

  // स्ट्रीम्स और लिसनर्स क्लीनअप करना
  @override
  void dispose() {
    _authSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}

// पूरे ऐप में इस्तेमाल होने वाला ग्लोबल इंस्टेंस
final appState = AppState.instance;
