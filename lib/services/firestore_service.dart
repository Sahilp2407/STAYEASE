import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/hotel_models.dart';
import '../models/plan_model.dart';
import '../models/budget_model.dart';

// ── FIRESTORE SERVICE: Database me data save, update, delete aur stream karne ke liye ──
class FirestoreService {
  // Pure app me single instance ke liye Singleton pattern
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  // Cloud Firestore database instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── USER PROFILE: User profile data Firestore me manage karne ke functions ──

  // Naya user profile document Firestore 'users' collection me create karna
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String phone = '',
    String photoUrl = '',
    String provider = 'password',
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      provider: provider,
      createdAt: now,
      updatedAt: now,
    );
    await _db.collection('users').doc(uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // Profile check karke create ya update karna bina overwriting ke
  Future<void> ensureUserProfile({
    required String uid,
    required String name,
    required String email,
    String phone = '',
    String photoUrl = '',
    String provider = 'password',
  }) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      await createUserProfile(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        provider: provider,
      );
    } else {
      await _db.collection('users').doc(uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
        if (name.isNotEmpty) 'name': name,
        if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (phone.isNotEmpty) 'phone': phone,
      });
    }
  }

  // UID se user ki profile data ek baar fetch karna
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // User profile me kisi bhi badlav ka real-time stream listen karna
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  // ── FAVORITES: User ke saved/wishlist hotels manage karne ke functions ──

  // User ke sabhi bookmarked/favorite hotel IDs ki real-time stream
  Stream<Set<String>> streamUserFavorites(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.id).toSet());
  }

  // Hotel ko user ke favorites subcollection me add karna
  Future<void> addFavorite({
    required String uid,
    required Hotel hotel,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(hotel.id)
        .set({
      'hotelId': hotel.id,
      'hotelName': hotel.name,
      'imageUrl': hotel.images.isNotEmpty ? hotel.images.first : '',
      'city': hotel.city,
      'price': hotel.pricePerNight,
      'rating': hotel.rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Hotel ko user ke favorites subcollection se hatana
  Future<void> removeFavorite({
    required String uid,
    required String hotelId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(hotelId)
        .delete();
  }

  // ── BOOKINGS: Hotel reservation aur booking history manage karne ke functions ──

  // Nayi booking ko user profile aur global bookings dono jagah save karna
  Future<void> saveBooking({
    required String uid,
    required Booking booking,
  }) async {
    final bookingData = booking.toFirestore();
    bookingData['userId'] = uid;

    final batch = _db.batch();

    // 1. Save in user's personal bookings subcollection
    final userBookingRef = _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(booking.id);
    batch.set(userBookingRef, bookingData);

    // 2. Save in top-level bookings collection for reference
    final globalBookingRef = _db.collection('bookings').doc(booking.id);
    batch.set(globalBookingRef, bookingData);

    await batch.commit();
  }

  // Booking ko cancel mark karna (user aur global record dono me)
  Future<void> cancelBooking({
    required String uid,
    required String bookingId,
  }) async {
    final batch = _db.batch();
    final updateData = {
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final userBookingRef = _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId);
    batch.update(userBookingRef, updateData);

    final globalBookingRef = _db.collection('bookings').doc(bookingId);
    batch.update(globalBookingRef, updateData);

    await batch.commit();
  }

  // User ki sari bookings date wise order karke real-time lana
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserBookings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .snapshots();
  }

  // ── TRIP PLANNING: Vacation aur trip itinerary plan karne ke functions ──

  // Naya trip plan Firestore 'plans' collection me create karna
  Future<void> createTripPlan(TripPlan trip) async {
    await _db.collection('plans').doc(trip.planId).set(trip.toFirestore());
  }

  // User ke sabhi trips ki real-time list lane ke liye stream
  Stream<List<TripPlan>> streamUserTrips(String uid) {
    return _db
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: 'trip')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TripPlan.fromFirestore(d)).toList());
  }

  // Trip me daily itinerary activity item add karna
  Future<void> addTripItineraryItem({
    required String planId,
    required TripItineraryItem item,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('itinerary')
        .doc(item.itemId)
        .set(item.toFirestore());
  }

  // Trip ke sare itinerary items date wise real-time fetch karna
  Stream<List<TripItineraryItem>> streamTripItinerary(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('itinerary')
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TripItineraryItem.fromFirestore(d)).toList());
  }

  // ── EVENT PLANNING: Wedding, Party aur Event plans manage karne ke functions ──

  // Naya event plan Firestore 'plans' collection me create karna
  Future<void> createEventPlan(EventPlan event) async {
    await _db.collection('plans').doc(event.planId).set(event.toFirestore());
  }

  // User ke dwara banaye gaye sabhi events ki real-time stream
  Stream<List<EventPlan>> streamUserEvents(String uid) {
    return _db
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: 'event')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventPlan.fromFirestore(d)).toList());
  }

  // Event plan ke checklist me task add karna
  Future<void> addPlanTask({
    required String planId,
    required PlanTask task,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('tasks')
        .doc(task.taskId)
        .set(task.toFirestore());
  }

  // Event me aane wale guest ki entry save karna
  Future<void> addPlanGuest({
    required String planId,
    required PlanGuest guest,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('guests')
        .doc(guest.guestId)
        .set(guest.toFirestore());
  }

  // Event ke catering/decor/DJ vendor ki entry save karna
  Future<void> addPlanVendor({
    required String planId,
    required PlanVendor vendor,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('vendors')
        .doc(vendor.vendorId)
        .set(vendor.toFirestore());
  }

  // ── BUDGET PLANNING: Trip/Event ka budget aur kharche track karne ke functions ──

  // Naya budget tracker create karna
  Future<void> createBudgetPlan(BudgetPlan budget) async {
    await _db.collection('budgets').doc(budget.budgetId).set(budget.toFirestore());
  }

  // User ke sabhi budgets ki real-time list fetch karna
  Stream<List<BudgetPlan>> streamUserBudgets(String uid) {
    return _db
        .collection('budgets')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BudgetPlan.fromFirestore(d)).toList());
  }

  // Expense add karke budget ka total spent automatically update karna
  Future<void> addExpense({
    required String budgetId,
    required ExpenseItem expense,
  }) async {
    final batch = _db.batch();

    // 1. Add expense document
    final expenseRef = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .doc(expense.expenseId);
    batch.set(expenseRef, expense.toFirestore());

    // 2. Increment budget actualSpent
    final budgetRef = _db.collection('budgets').doc(budgetId);
    batch.update(budgetRef, {
      'actualSpent': FieldValue.increment(expense.amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Budget ke sare expenses ki real-time stream
  Stream<List<ExpenseItem>> streamBudgetExpenses(String budgetId) {
    return _db
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ExpenseItem.fromFirestore(d)).toList());
  }

  // Expense delete karke budget ka total spent ghata dena
  Future<void> deleteExpense({
    required String budgetId,
    required String expenseId,
    required double amount,
  }) async {
    final batch = _db.batch();
    final expenseRef = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .doc(expenseId);
    batch.delete(expenseRef);
    final budgetRef = _db.collection('budgets').doc(budgetId);
    batch.update(budgetRef, {
      'actualSpent': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  // Ek specific budget ka live data stream karna
  Stream<BudgetPlan?> streamBudget(String budgetId) {
    return _db.collection('budgets').doc(budgetId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BudgetPlan.fromFirestore(doc);
    });
  }

  // Budget details jaise total budget ya category limit update karna
  Future<void> updateBudgetField(
      String budgetId, Map<String, dynamic> data) async {
    await _db.collection('budgets').doc(budgetId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── PLAN CRUD: Plan delete ya update karne ke functions ──

  // Kisi bhi plan ko ID ke through delete karna
  Future<void> deletePlan(String planId) async {
    await _db.collection('plans').doc(planId).delete();
  }

  // Plan ki title, dates ya details update karna
  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    await _db.collection('plans').doc(planId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Plan ka live data listen karna
  Stream<Map<String, dynamic>?> streamPlan(String planId) {
    return _db.collection('plans').doc(planId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  // ── ITINERARY MANAGEMENT: Daily schedule edit ya delete karne ke functions ──

  // Itinerary schedule item ko update karna
  Future<void> updateItineraryItem({
    required String planId,
    required String itemId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('itinerary')
        .doc(itemId)
        .update(data);
  }

  // Itinerary item ko delete karna
  Future<void> deleteItineraryItem({
    required String planId,
    required String itemId,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('itinerary')
        .doc(itemId)
        .delete();
  }

  // ── TASKS MANAGEMENT: Plan tasks status aur deadlines manage karna ──

  // Plan ke sare tasks due date ke order me stream karna
  Stream<List<PlanTask>> streamTasks(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlanTask.fromFirestore(d)).toList());
  }

  // Task ka status (done/pending) ya details update karna
  Future<void> updateTask({
    required String planId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  // Task ko delete karna
  Future<void> deleteTask({
    required String planId,
    required String taskId,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ── GUESTS MANAGEMENT: Guest list aur RSVP track karne ke functions ──

  // Event ke sare guests ki real-time list fetch karna
  Stream<List<PlanGuest>> streamGuests(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('guests')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlanGuest.fromFirestore(d)).toList());
  }

  // Guest ka RSVP status (confirmed/declined) update karna
  Future<void> updateGuest({
    required String planId,
    required String guestId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('guests')
        .doc(guestId)
        .update(data);
  }

  // Guest ko list se delete karna
  Future<void> deleteGuest({
    required String planId,
    required String guestId,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('guests')
        .doc(guestId)
        .delete();
  }

  // ── VENDORS MANAGEMENT: Vendors list aur payment status manage karna ──

  // Event ke sabhi vendors ki real-time stream
  Stream<List<PlanVendor>> streamVendors(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('vendors')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlanVendor.fromFirestore(d)).toList());
  }

  // Vendor ka payment status ya details update karna
  Future<void> updateVendor({
    required String planId,
    required String vendorId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('vendors')
        .doc(vendorId)
        .update(data);
  }

  // Vendor ko list se delete karna
  Future<void> deleteVendor({
    required String planId,
    required String vendorId,
  }) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('vendors')
        .doc(vendorId)
        .delete();
  }
}
