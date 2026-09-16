import 'package:cloud_firestore/cloud_firestore.dart';

// Plan ka type: trip (tour/holiday) ya event (wedding/party)
enum PlanType {
  trip,
  event,
}

// ── TRIP PLAN: Vacation aur holiday itinerary planning ka model ──
class TripPlan {
  final String planId;
  final String userId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int travellers;
  final String travelStyle;
  final List<String> interests;
  final String? budgetId;
  final String? hotelBookingId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor: TripPlan instance initialize karne ke liye
  const TripPlan({
    required this.planId,
    required this.userId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.travellers = 2,
    this.travelStyle = 'Luxury Boutique',
    this.interests = const [],
    this.budgetId,
    this.hotelBookingId,
    required this.createdAt,
    required this.updatedAt,
  });

  // TripPlan object ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'type': 'trip',
      'title': title,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'travellers': travellers,
      'travelStyle': travelStyle,
      'interests': interests,
      'budgetId': budgetId,
      'hotelBookingId': hotelBookingId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore DocumentSnapshot se TripPlan object parse karna
  factory TripPlan.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TripPlan(
      planId: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? 'Trip to ${data['destination'] ?? 'India'}',
      destination: data['destination'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 3)),
      travellers: (data['travellers'] as num?)?.toInt() ?? 2,
      travelStyle: data['travelStyle'] as String? ?? 'Luxury Boutique',
      interests: (data['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      budgetId: data['budgetId'] as String?,
      hotelBookingId: data['hotelBookingId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── TRIP ITINERARY: Trip ke daily activities aur time-schedule ka model ──
class TripItineraryItem {
  final String itemId;
  final DateTime date;
  final String time;
  final String title;
  final String location;
  final String category;
  final String notes;
  final double estimatedCost;
  final bool completed;

  // Constructor: Itinerary activity item initialize karne ke liye
  const TripItineraryItem({
    required this.itemId,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.category,
    this.notes = '',
    this.estimatedCost = 0.0,
    this.completed = false,
  });

  // Itinerary item ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'date': Timestamp.fromDate(date),
      'time': time,
      'title': title,
      'location': location,
      'category': category,
      'notes': notes,
      'estimatedCost': estimatedCost,
      'completed': completed,
    };
  }

  // Firestore Document se Itinerary item parse karna
  factory TripItineraryItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TripItineraryItem(
      itemId: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      title: data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      category: data['category'] as String? ?? 'Activity',
      notes: data['notes'] as String? ?? '',
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      completed: data['completed'] as bool? ?? false,
    );
  }
}

// ── EVENT PLAN: Wedding, Party ya Conference planning ka model ──
class EventPlan {
  final String planId;
  final String userId;
  final String eventName;
  final String eventType;
  final DateTime date;
  final String time;
  final String location;
  final int expectedGuests;
  final String? budgetId;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor: EventPlan initialize karne ke liye
  const EventPlan({
    required this.planId,
    required this.userId,
    required this.eventName,
    required this.eventType,
    required this.date,
    required this.time,
    required this.location,
    this.expectedGuests = 50,
    this.budgetId,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // EventPlan object ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'type': 'event',
      'eventName': eventName,
      'eventType': eventType,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'expectedGuests': expectedGuests,
      'budgetId': budgetId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore Document se EventPlan object parse karna
  factory EventPlan.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventPlan(
      planId: doc.id,
      userId: data['userId'] as String? ?? '',
      eventName: data['eventName'] as String? ?? '',
      eventType: data['eventType'] as String? ?? 'Celebration',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      expectedGuests: (data['expectedGuests'] as num?)?.toInt() ?? 50,
      budgetId: data['budgetId'] as String?,
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── PLAN TASK: Event ya trip ke pending to-do task ka model ──
class PlanTask {
  final String taskId;
  final String title;
  final DateTime? dueDate;
  final String priority; // 'High', 'Medium', 'Low'
  final bool completed;

  // Constructor: PlanTask initialize karne ke liye
  const PlanTask({
    required this.taskId,
    required this.title,
    this.dueDate,
    this.priority = 'Medium',
    this.completed = false,
  });

  // Task ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'title': title,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
      'completed': completed,
    };
  }

  // Firestore Document se Task parse karna
  factory PlanTask.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlanTask(
      taskId: doc.id,
      title: data['title'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      priority: data['priority'] as String? ?? 'Medium',
      completed: data['completed'] as bool? ?? false,
    );
  }
}

// ── PLAN GUEST: Event ke guest aur RSVP status ka model ──
class PlanGuest {
  final String guestId;
  final String name;
  final String contact; // phone or email
  final String rsvpStatus; // 'Confirmed', 'Invited', 'Declined', 'Pending'

  // Constructor: PlanGuest initialize karne ke liye
  const PlanGuest({
    required this.guestId,
    required this.name,
    required this.contact,
    this.rsvpStatus = 'Pending',
  });

  // Guest data ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'guestId': guestId,
      'name': name,
      'contact': contact,
      'rsvpStatus': rsvpStatus,
    };
  }

  // Firestore Document se Guest parse karna
  factory PlanGuest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlanGuest(
      guestId: doc.id,
      name: data['name'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      rsvpStatus: data['rsvpStatus'] as String? ?? 'Pending',
    );
  }
}

// ── PLAN VENDOR: Catering, Decor, DJ ityadi vendors ka model ──
class PlanVendor {
  final String vendorId;
  final String category;
  final String vendorName;
  final String contact;
  final double estimatedCost;
  final double actualCost;
  final String status; // 'Pending', 'Contacted', 'Confirmed', 'Cancelled'
  final String notes;

  // Constructor: PlanVendor initialize karne ke liye
  const PlanVendor({
    required this.vendorId,
    required this.category,
    required this.vendorName,
    required this.contact,
    this.estimatedCost = 0.0,
    this.actualCost = 0.0,
    this.status = 'Pending',
    this.notes = '',
  });

  // Vendor data ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'vendorId': vendorId,
      'category': category,
      'vendorName': vendorName,
      'contact': contact,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'status': status,
      'notes': notes,
    };
  }

  // Firestore Document se Vendor data parse karna
  factory PlanVendor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PlanVendor(
      vendorId: doc.id,
      category: data['category'] as String? ?? '',
      vendorName: data['vendorName'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      actualCost: (data['actualCost'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'Pending',
      notes: data['notes'] as String? ?? '',
    );
  }
}
