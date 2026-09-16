import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// बुकिंग की वर्तमान स्थिति (Upcoming, Completed, Cancelled)
enum BookingStatus {
  upcoming,
  completed,
  cancelled,
}

// ── ROOM MODEL: होटल के कमरों के प्रकार, सुविधाएं और किराया ──
class Room {
  final String id;
  final String name;
  final int capacity;
  final String bedType;
  final int pricePerNight;
  final List<String> amenities;
  final String cancellationPolicy;
  final bool breakfastIncluded;
  final String imageUrl;

  // Constructor: Room मॉडल इनिशियलाइज़ करने के लिए
  const Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.bedType,
    required this.pricePerNight,
    required this.amenities,
    required this.cancellationPolicy,
    required this.breakfastIncluded,
    required this.imageUrl,
  });
}

// ── GUEST REVIEW: होटल पर गेस्ट द्वारा दी गई रेटिंग और रिव्यू ──
class GuestReview {
  final String author;
  final String avatarUrl;
  final double rating;
  final String date;
  final String comment;

  // Constructor: GuestReview इनिशियलाइज़ करने के लिए
  const GuestReview({
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

// ── HOTEL MODEL: होटल की पूरी जानकारी (लोकेशन, रेटिंग, तस्वीरें, कमरे) ──
class Hotel {
  final String id;
  final String name;
  final String category; // e.g. "★★★★★ Luxury Hotel"
  final double rating;
  final int reviewsCount;
  final String city;
  final String location;
  final String distanceDescription; // e.g. "0.8 km from Gateway of India"
  final int pricePerNight;
  final int priceInclTaxes;
  final List<String> amenities; // e.g. ["Wi-Fi", "Pool", "Breakfast", "Parking"]
  final String defaultRoomType; // e.g. "Deluxe King Room"
  final String cancellationPolicy; // e.g. "Free cancellation"
  final String breakfastInfo; // e.g. "Breakfast included"
  final List<String> images;
  final String badge; // "Top Rated", "Best Value", "Popular", or empty
  final String description;
  final double latitude;
  final double longitude;
  final List<Room> rooms;
  final List<GuestReview> reviews;
  final Color heroColor1;
  final Color heroColor2;

  // Constructor: Hotel मॉडल इनिशियलाइज़ करने के लिए
  const Hotel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.city,
    required this.location,
    required this.distanceDescription,
    required this.pricePerNight,
    required this.priceInclTaxes,
    required this.amenities,
    required this.defaultRoomType,
    required this.cancellationPolicy,
    required this.breakfastInfo,
    required this.images,
    required this.badge,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.rooms,
    required this.reviews,
    required this.heroColor1,
    required this.heroColor2,
  });
}

// ── BOOKING MODEL: यूजर की कन्फर्म्ड या कैंसिल्ड होटल बुकिंग का रिकॉर्ड ──
class Booking {
  final String id; // e.g. "#STY928374"
  final String userId;
  final Hotel hotel;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int adults;
  final int roomsCount;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String specialRequests;
  final int roomTotal;
  final int taxes;
  final int serviceFee;
  final int totalAmount;
  final BookingStatus status;
  final String paymentMethod;
  final DateTime bookedAt;

  // Constructor: Booking इनिशियलाइज़ करने के लिए
  const Booking({
    required this.id,
    this.userId = '',
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.adults,
    required this.roomsCount,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    this.specialRequests = '',
    required this.roomTotal,
    required this.taxes,
    required this.serviceFee,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.bookedAt,
  });

  // Booking डेटा को Firestore JSON Map में कन्वर्ट करना
  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': id,
      'userId': userId,
      'hotelId': hotel.id,
      'hotelName': hotel.name,
      'hotelImage': hotel.images.isNotEmpty ? hotel.images.first : '',
      'hotelLocation': hotel.location,
      'roomId': room.id,
      'roomName': room.name,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'nights': nights,
      'adults': adults,
      'roomsCount': roomsCount,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'specialRequests': specialRequests,
      'roomTotal': roomTotal,
      'taxes': taxes,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'paid',
      'currency': 'INR',
      'bookedAt': Timestamp.fromDate(bookedAt),
      'createdAt': Timestamp.fromDate(bookedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// ── HOTEL FILTER: होटल सर्च और फ़िल्टरिंग के पैरामीटर्स ──
class HotelFilter {
  RangeValues priceRange;
  double minRating;
  List<String> hotelTypes;
  List<String> amenities;
  List<String> policies;
  String sortBy;

  // Constructor: होटल फ़िल्टर डिफ़ॉल्ट्स इनिशियलाइज़ करने के लिए
  HotelFilter({
    this.priceRange = const RangeValues(1000, 30000),
    this.minRating = 0.0,
    List<String>? hotelTypes,
    List<String>? amenities,
    List<String>? policies,
    this.sortBy = 'Recommended',
  })  : hotelTypes = hotelTypes ?? [],
        amenities = amenities ?? [],
        policies = policies ?? [];

  // फ़िल्टर स्टेट की कॉपी बनाने के लिए
  HotelFilter clone() {
    return HotelFilter(
      priceRange: priceRange,
      minRating: minRating,
      hotelTypes: List.from(hotelTypes),
      amenities: List.from(amenities),
      policies: List.from(policies),
      sortBy: sortBy,
    );
  }
}
