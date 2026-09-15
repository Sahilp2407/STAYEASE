import 'package:flutter/material.dart';
import '../models/hotel_models.dart';
import '../data/hotel_data.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    // Initial sample booking for "Completed" tab
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
  }

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName.isNotEmpty ? _userName : 'Sahil Pandey';
  String get userEmail => _userEmail.isNotEmpty ? _userEmail : 'sahil@stayease.com';
  String get userPhone => _userPhone.isNotEmpty ? _userPhone : '+91 98200 12345';

  final Set<String> _favoriteIds = {'hotel-01'};
  Set<String> get favoriteIds => _favoriteIds;
  Set<String> get favoriteHotelIds => _favoriteIds;

  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  bool isFavorite(String hotelId) => _favoriteIds.contains(hotelId);

  void toggleFavorite(String hotelId) {
    if (_favoriteIds.contains(hotelId)) {
      _favoriteIds.remove(hotelId);
    } else {
      _favoriteIds.add(hotelId);
    }
    notifyListeners();
  }

  void login({String? name, String? email, String? phone}) {
    _isLoggedIn = true;
    _userName = name ?? 'Sahil Pandey';
    _userEmail = email ?? 'sahil@stayease.com';
    _userPhone = phone ?? '+91 98200 12345';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    notifyListeners();
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final old = _bookings[idx];
      _bookings[idx] = Booking(
        id: old.id,
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
    }
  }
}

final appState = AppState.instance;
