# 🔥 STAYEASE — Complete Firebase Architecture & Code Explanation Guide

> **दस्तावेज़ का उद्देश्य (Purpose):** यह गाइड StayEase Flutter एप्लिकेशन के पूरे **Firebase Integration** को आसान, स्पष्ट और विस्तार से समझाने के लिए बनाई गई है। इसमें Firebase Authentication, Cloud Firestore Database, Data Models, Security Rules, Batch Writes, Reactive Streams और UI Integration का एक-एक कोड ब्लॉक डिटेल में समझाया गया है।

---

## 📑 विषय-सूची (Table of Contents)

1. [Firebase Architecture Overview](#1-firebase-architecture-overview)
2. [Project Setup & Configuration Files](#2-project-setup--configuration-files)
   - `google-services.json`
   - `firebase_options.dart`
   - `lib/main.dart` (Firebase Initialization)
3. [Authentication Deep Dive (`lib/services/auth_service.dart`)](#3-authentication-deep-dive)
   - Singleton Pattern
   - Email/Password Login & Registration
   - Google Sign-In (Mobile + Web Hybrid)
   - Phone Number & OTP Verification
   - Password Reset & Sign Out
   - User-Friendly Error Mapper
4. [Firestore Database Architecture (`lib/services/firestore_service.dart`)](#4-firestore-database-architecture)
   - Database Collections Schema (Tree Structure)
   - User Profiles & Auto-Provisioning (`ensureUserProfile`)
   - Favorites Subcollection (`Stream<Set<String>>`)
   - Hotel Bookings with Atomic Batch Writes (`_db.batch()`)
   - Trip Planning & Itinerary Operations
   - Event Planning (Tasks, Guests, Vendors)
   - Budget Planning & Auto-Incrementing Expenses (`FieldValue.increment`)
5. [Data Models & Serialization (To/From Firestore)](#5-data-models--serialization)
   - `UserProfile` (`lib/models/user_model.dart`)
   - `TripPlan` & `EventPlan` (`lib/models/plan_model.dart`)
   - `BudgetPlan` & `ExpenseItem` (`lib/models/budget_model.dart`)
   - `Booking` Model (`lib/models/hotel_models.dart`)
6. [Firestore Security Rules (`firestore.rules`)](#6-firestore-security-rules)
   - Helper Functions (`isAuthenticated`, `isOwner`)
   - Collection-by-Collection Security Breakdown
7. [Frontend & UI Integration (How UI talks to Firebase)](#7-frontend--ui-integration)
   - `AuthScreen` Flow
   - `StreamBuilder` Reactive UI Pattern
8. [Common Viva / Interview Questions & Answers](#8-common-viva--interview-questions--answers)

---

## 1. Firebase Architecture Overview

StayEase में Firebase को **Boutique Luxury Hospitality Concierge** की तरह डिज़ाइन किया गया है। यहाँ Data Flow 3 प्रमुख परतों (Layers) में काम करता है:

```
┌─────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                    │
│      AuthScreen  │  Dashboard  │  PlansHub  │  BookingFlow  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Calls / Listens to
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER                        │
│   AuthService (Singleton)    │ FirestoreService (Singleton) │
└──────────────────────────────┬──────────────────────────────┘
                               │ Serializes / Deserializes
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         MODEL LAYER                         │
│   UserProfile  │  Booking  │  TripPlan  │  BudgetPlan  ...  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Network / Stream
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND (CLOUD)                 │
│      Firebase Auth       │       Cloud Firestore DB         │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Highlights:
1. **Single Source of Truth**: Data models में `toFirestore()` और `fromFirestore()` फ़ैक्टरी मेथड्स का इस्तेमाल ताकि डाटा टाइप-सेफ रहे।
2. **Atomic Batch Writes**: बुकिंग और बजट ट्रांजेक्शन में `WriteBatch` का इस्तेमाल ताकि या तो पूरा ऑपरेशन सफल हो, या फिर कुछ भी करप्ट न हो।
3. **Reactive Streams**: UI `FutureBuilder` की जगह `StreamBuilder` का इस्तेमाल करता है, जिससे डेटाबेस में बदलाव होते ही बिना पेज रीलोड किए स्क्रीन लाइव अपडेट हो जाती है।

---

## 2. Project Setup & Configuration Files

### 2.1 `google-services.json`
यह फ़ाइल Firebase Console से डाउनलोड होती है और Android प्रोजेक्ट को Firebase सर्वर से कनेक्ट करती है।

- **Location**: `android/app/google-services.json`
- **Package Name**: `com.stayease.stayease`
- **Project ID**: `stayease-app-e760b`
- **OAuth 2.0 Clients**: Google Sign-In के लिए Web Client ID (`1020746309841-i82a6m1b2rgrqn0euor9i61q9udm09vg.apps.googleusercontent.com`) और SHA-1 फिंगरप्रिंट रजिस्टर्ड हैं।

### 2.2 `lib/firebase_options.dart`
FlutterFire CLI द्वारा जनरेटेड क्रॉस-प्लेटफ़ॉर्म कॉन्फ़िगरेशन फ़ाइल है। यह Android, iOS और Web के लिए API Keys, App IDs और Storage Buckets प्रोवाइड करती है:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      ...
    }
  }
}
```

### 2.3 `lib/main.dart` — Firebase Initialization
App स्टार्ट होते ही सबसे पहले Firebase को इनिशियलाइज़ किया जाता है:

```dart
void main() async {
  // 1. Flutter Engine के बाइंडिंग्स को इनिशियलाइज़ करना जरूरी है async main के लिए
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase App को प्लेटफॉर्म-स्पेसिफिक ऑप्शन्स के साथ बूटस्ट्रैप करना
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // 3. Status Bar & UI Styling
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(const StayEaseApp());
}
```

> **Why `WidgetsFlutterBinding.ensureInitialized()`?**
> Flutter में `runApp()` कॉल होने से पहले अगर कोई भी Native Platform Channel (जैसे Firebase) कॉल करना हो, तो BinaryMessenger को तैयार करने के लिए यह पहली लाइन अनिवार्य होती है।

---

## 3. Authentication Deep Dive (`lib/services/auth_service.dart`)

`AuthService` क्लास पूरे एप्लिकेशन में ऑथेंटिकेशन का एकलौता कंट्रोलर (Single Controller) है।

### 3.1 Singleton Pattern
```dart
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1020746309841-i82a6m1b2rgrqn0euor9i61q9udm09vg.apps.googleusercontent.com',
  );
```
- **फायदा**: पूरे ऐप में सिर्फ एक `AuthService` इंस्टेंस मेमोरी में रहता है। कोई भी स्क्रीन `AuthService.instance.signIn(...)` से सीधे कॉल कर सकती है।

---

### 3.2 State Observers
```dart
User? get currentUser => _auth.currentUser;
Stream<User?> get authStateChanges => _auth.authStateChanges();
```
- `currentUser`: करंट लॉग्ड-इन यूज़र का ऑब्जेक्ट लौटाता है (या `null` अगर लॉगआउट है)।
- `authStateChanges`: एक लाइव `Stream` है। जैसे ही यूज़र लॉगिन, लॉगआउट या टोकन रीफ़्रेश करता है, यह स्ट्रीम तुरंत नया इवेंट एमिट करती है।

---

### 3.3 Email & Password Sign In
```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null) {
      // Login होते ही Firestore में यूज़र प्रोफ़ाइल का एक्सिस्टेंस चेक करना
      await FirestoreService.instance.ensureUserProfile(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? 'StayEase Guest',
        email: cred.user!.email ?? email.trim(),
        phone: cred.user!.phoneNumber ?? '',
        provider: 'password',
      );
    }
    return cred;
  } on FirebaseAuthException {
    rethrow; // कॉलिंग UI को सही एरर कोड भेजने के लिए
  } catch (e) {
    throw FirebaseAuthException(code: 'unknown', message: e.toString());
  }
}
```

---

### 3.4 Email & Password Registration (Sign Up)
```dart
Future<UserCredential> signUpWithEmailAndPassword({
  required String name,
  required String email,
  required String password,
  String? phone,
}) async {
  try {
    // 1. Firebase Auth में क्रेडेंशियल्स बनाना
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null) {
      // 2. Firebase Auth के प्रोफाइल में नाम अपडेट करना
      await cred.user!.updateDisplayName(name.trim());

      // 3. Cloud Firestore के `users` कलेक्शन में पूरा दस्तावेज़ तैयार करना
      await FirestoreService.instance.createUserProfile(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone ?? '',
        provider: 'password',
      );
    }
    return cred;
  } on FirebaseAuthException {
    rethrow;
  }
}
```

---

### 3.5 Google Sign-In (Web + Mobile Hybrid)
Google Sign-In मोबाइल (Android/iOS) और वेब दोनों पर अलग-अलग तरीक़े से काम करता है:

```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      // Web पर Popup Flow इस्तेमाल होता है
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      final cred = await _auth.signInWithPopup(googleProvider);
      if (cred.user != null) {
        await FirestoreService.instance.ensureUserProfile(...);
      }
      return cred;
    } else {
      // Mobile पर Native Google Account Picker आता है
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // यूज़र ने कैंसिल कर दिया

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Google के Access Token और ID Token से Firebase क्रेडेंशियल बनाना
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        await FirestoreService.instance.ensureUserProfile(
          uid: cred.user!.uid,
          name: cred.user!.displayName ?? googleUser.displayName ?? 'Google Guest',
          email: cred.user!.email ?? googleUser.email,
          photoUrl: cred.user!.photoURL ?? googleUser.photoUrl ?? '',
          provider: 'google.com',
        );
      }
      return cred;
    }
  } on FirebaseAuthException {
    rethrow;
  }
}
```

---

### 3.6 Phone Authentication & OTP Verification

Phone Auth दो-चरणीय (2-step) प्रक्रिया है:

#### स्टेप 1: OTP भेजना (`verifyPhoneNumber`)
```dart
Future<void> verifyPhoneNumber({
  required String phoneNumber,
  required Function(String verificationId, int? resendToken) onCodeSent,
  required Function(PhoneAuthCredential credential) onVerificationCompleted,
  required Function(FirebaseAuthException exception) onVerificationFailed,
  required Function(String verificationId) onCodeAutoRetrievalTimeout,
}) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: onVerificationCompleted, // Android Auto-read SMS
    verificationFailed: onVerificationFailed,
    codeSent: onCodeSent,                           // जब SMS भेजा जा चुका हो
    codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    timeout: const Duration(seconds: 60),
  );
}
```

#### स्टेप 2: OTP कन्फर्म करना (`signInWithOtp`)
```dart
Future<UserCredential> signInWithOtp({
  required String verificationId,
  required String smsCode,
}) async {
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode.trim(),
  );
  final cred = await _auth.signInWithCredential(credential);
  if (cred.user != null) {
    await FirestoreService.instance.ensureUserProfile(
      uid: cred.user!.uid,
      name: cred.user!.displayName ?? 'Phone Guest',
      email: cred.user!.email ?? '',
      phone: cred.user!.phoneNumber ?? '',
      provider: 'phone',
    );
  }
  return cred;
}
```

---

### 3.7 Error Handling Mapper (`getErrorMessage`)
Firebase के तकनीकी एरर कोड्स (जैसे `wrong-password`) को आम यूज़र के समझने योग्य संदेश में बदलने के लिए:

```dart
static String getErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'invalid-verification-code':
        return 'The verification code entered is invalid. Please check and try again.';
      default:
        return error.message ?? 'An unexpected authentication error occurred.';
    }
  }
  return error.toString();
}
```

---

## 4. Firestore Database Architecture (`lib/services/firestore_service.dart`)

### 4.1 Collections & Subcollections Tree
Cloud Firestore में StayEase का पूरा नो-एसक्यूएल (NoSQL) स्कीमा इस प्रकार है:

```
firestore/
├── users/ (Collection)
│   └── {uid}/ (Document)
│       ├── name, email, phone, photoUrl, provider, createdAt, updatedAt
│       ├── favorites/ (Subcollection)
│       │   └── {hotelId}/ (Document: hotelName, price, city, rating)
│       └── bookings/ (Subcollection)
│           └── {bookingId}/ (Document: hotel, dates, guests, totalAmount, status)
│
├── bookings/ (Collection - Global Registry)
│   └── {bookingId}/ (Document: copy of booking with userId for admin/queries)
│
├── plans/ (Collection - Trips & Events)
│   └── {planId}/ (Document: userId, title, type: 'trip'|'event', budget, dates)
│       ├── itinerary/ (Subcollection - For Trips)
│       │   └── {itemId}/ (title, dayNumber, time, location, cost)
│       ├── tasks/ (Subcollection - For Events)
│       │   └── {taskId}/ (title, priority, isCompleted, dueDate)
│       ├── guests/ (Subcollection - For Events)
│       │   └── {guestId}/ (name, contact, rsvpStatus, plusOnes)
│       └── vendors/ (Subcollection - For Events)
│           └── {vendorId}/ (name, category, price, isPaid)
│
└── budgets/ (Collection)
    └── {budgetId}/ (Document: userId, planId, totalBudget, actualSpent)
        └── expenses/ (Subcollection)
            └── {expenseId}/ (title, amount, category, date)
```

---

### 4.2 User Profiles & `ensureUserProfile`
हर बार जब कोई सोशल लॉगिन (Google या Phone) से आता है, तो हमें चेक करना होता है कि उसका डॉक्यूमेंट बना है या नहीं:

```dart
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
    // नया यूज़र है -> डॉक्यूमेंट बनाओ
    await createUserProfile(
      uid: uid, name: name, email: email,
      phone: phone, photoUrl: photoUrl, provider: provider,
    );
  } else {
    // पुराना यूज़र है -> सिर्फ updatedAt और डिटेल्स रीफ्रेश करो
    await _db.collection('users').doc(uid).update({
      'updatedAt': FieldValue.serverTimestamp(),
      if (name.isNotEmpty) 'name': name,
      if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      if (phone.isNotEmpty) 'phone': phone,
    });
  }
}
```

---

### 4.3 Realtime Favorites Subcollection
होटल को विशलिस्ट/फेवरेट में सेव करने के लिए:

```dart
// 1. Live Stream: सिर्फ IDs का Set रिटर्न करता है UI में फास्ट ओ(1) लुकअप के लिए
Stream<Set<String>> streamUserFavorites(String uid) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('favorites')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((d) => d.id).toSet());
}

// 2. Add Favorite
Future<void> addFavorite({required String uid, required Hotel hotel}) async {
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

// 3. Remove Favorite
Future<void> removeFavorite({required String uid, required String hotelId}) async {
  await _db
      .collection('users')
      .doc(uid)
      .collection('favorites')
      .doc(hotelId)
      .delete();
}
```

---

### 4.4 Hotel Bookings — Atomic Batch Writes (`_db.batch()`)
जब कोई यूज़र रूम बुक करता है, तो डेटा को **User की सब-कलेक्शन** और **Global Bookings** दोनों जगह एक साथ लिखना होता है ताकि डेटा कभी भी इनकन्सिस्टेंट (Inconsistent) न हो:

```dart
Future<void> saveBooking({
  required String uid,
  required Booking booking,
}) async {
  final bookingData = booking.toFirestore();
  bookingData['userId'] = uid;

  // Batch Transaction शुरू करना
  final batch = _db.batch();

  // 1. यूज़र के पर्सनल सब-कलेक्शन में एंट्री
  final userBookingRef = _db
      .collection('users')
      .doc(uid)
      .collection('bookings')
      .doc(booking.id);
  batch.set(userBookingRef, bookingData);

  // 2. टॉप-लेवल ग्लोबल रजिस्ट्री में एंट्री
  final globalBookingRef = _db.collection('bookings').doc(booking.id);
  batch.set(globalBookingRef, bookingData);

  // दोनों ऑपरेशन्स एक साथ कमिट होंगे (Atomic Commit)
  await batch.commit();
}
```

#### Booking Cancellation:
```dart
Future<void> cancelBooking({
  required String uid,
  required String bookingId,
}) async {
  final batch = _db.batch();
  final updateData = {
    'status': BookingStatus.cancelled.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  batch.update(_db.collection('users').doc(uid).collection('bookings').doc(bookingId), updateData);
  batch.update(_db.collection('bookings').doc(bookingId), updateData);

  await batch.commit();
}
```

---

### 4.5 Trip & Event Planning
Trips और Events को एक ही `plans` कलेक्शन में रखा गया है जहाँ `type` फ़ील्ड `'trip'` या `'event'` होता है:

```dart
// Trip Create करना
Future<void> createTripPlan(TripPlan trip) async {
  await _db.collection('plans').doc(trip.planId).set(trip.toFirestore());
}

// यूज़र के सारे ट्रिप्स की रियल-टाइम स्ट्रीम
Stream<List<TripPlan>> streamUserTrips(String uid) {
  return _db
      .collection('plans')
      .where('userId', isEqualTo: uid)
      .where('type', isEqualTo: 'trip')
      .snapshots()
      .map((snap) => snap.docs.map((d) => TripPlan.fromFirestore(d)).toList());
}

// Event Create करना
Future<void> createEventPlan(EventPlan event) async {
  await _db.collection('plans').doc(event.planId).set(event.toFirestore());
}

// यूज़र के सारे इवेंट्स की रियल-टाइम स्ट्रीम
Stream<List<EventPlan>> streamUserEvents(String uid) {
  return _db
      .collection('plans')
      .where('userId', isEqualTo: uid)
      .where('type', isEqualTo: 'event')
      .snapshots()
      .map((snap) => snap.docs.map((d) => EventPlan.fromFirestore(d)).toList());
}
```

---

### 4.6 Budget & Expense Management (`FieldValue.increment`)
जब यूज़र कोई नया खर्चा (Expense) जोड़ता है, तो Firestore का `FieldValue.increment()` सर्वर पर सुरक्षित तरीक़े से टोटल अमाउंट को अपडेट करता है:

```dart
Future<void> addExpense({
  required String budgetId,
  required ExpenseItem expense,
}) async {
  final batch = _db.batch();

  // 1. सब-कलेक्शन में नया खर्चा जोड़ना
  final expenseRef = _db
      .collection('budgets')
      .doc(budgetId)
      .collection('expenses')
      .doc(expense.expenseId);
  batch.set(expenseRef, expense.toFirestore());

  // 2. मुख्य बजट दस्तावेज़ में `actualSpent` को एटॉमिक तरीक़े से बढ़ाना
  final budgetRef = _db.collection('budgets').doc(budgetId);
  batch.update(budgetRef, {
    'actualSpent': FieldValue.increment(expense.amount),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  await batch.commit();
}
```

> **Why `FieldValue.increment` instead of local addition?**
> अगर आप क्लाइंट साइड पर `actualSpent + amount` करके भेजेंगे, तो नेटवर्क लेटेंसी या दो डिवाइस से एक साथ खर्चा जोड़ने पर Race Condition हो जाएगी। `FieldValue.increment()` डेटाबेस सर्वर पर सीधे वैल्यू बढ़ाता है, जिससे 100% सही जोड़ मिलता है।

---

## 5. Data Models & Serialization

Flutter के Dart ऑब्जेक्ट्स को Firestore के JSON/Map में बदलने के लिए `toFirestore()` और Firestore डॉक्यूमेंट से Dart ऑब्जेक्ट बनाने के लिए `fromFirestore()` का इस्तेमाल होता है।

### 5.1 `UserProfile` Model (`lib/models/user_model.dart`)
```dart
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String provider;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Dart Object -> Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'provider': provider,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore Document Snapshot -> Dart Object
  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] as String? ?? 'Guest',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      provider: data['provider'] as String? ?? 'password',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

---

## 6. Firestore Security Rules (`firestore.rules`)

StayEase के सिक्योरिटी रूल्स Zero-Trust आर्किटेक्चर पर काम करते हैं।

### 6.1 Helper Functions
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // यूज़र का लॉगिन होना अनिवार्य है
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // यूज़र वही है जिसका डेटा वह एक्सेस कर रहा है
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
```

### 6.2 Security Rules Breakdown
```javascript
    // 1. User Profiles, Favorites & User Bookings
    // केवल वही यूज़र अपना प्रोफ़ाइल, विशलिस्ट और बुकिंग देख या बदल सकता है
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /favorites/{hotelId} {
        allow read, write: if isOwner(userId);
      }

      match /bookings/{bookingId} {
        allow read, write: if isOwner(userId);
      }
    }

    // 2. Global Bookings Reference
    // यूज़र सिर्फ अपनी बुकिंग पढ़ सकता है या बना सकता है, डिलीट करना वर्जित है
    match /bookings/{bookingId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow delete: if false; // ऑडिट ट्रेल के लिए डिलीट बैन है
    }

    // 3. Plans (Trips & Events) and Subcollections
    // सब-कलेक्शंस के लिए पैरेंट प्लान का ओनरशिप चेक
    match /plans/{planId} {
      allow read, write: if isAuthenticated() && (resource == null || resource.data.userId == request.auth.uid);

      match /itinerary/{itemId} {
        allow read, write: if isAuthenticated() &&
          get(/databases/$(database)/documents/plans/$(planId)).data.userId == request.auth.uid;
      }

      match /tasks/{taskId} {
        allow read, write: if isAuthenticated() &&
          get(/databases/$(database)/documents/plans/$(planId)).data.userId == request.auth.uid;
      }

      match /guests/{guestId} {
        allow read, write: if isAuthenticated() &&
          get(/databases/$(database)/documents/plans/$(planId)).data.userId == request.auth.uid;
      }
    }

    // 4. Budgets & Expenses
    match /budgets/{budgetId} {
      allow read, write: if isAuthenticated() && (resource == null || resource.data.userId == request.auth.uid);

      match /expenses/{expenseId} {
        allow read, write: if isAuthenticated() &&
          get(/databases/$(database)/documents/budgets/$(budgetId)).data.userId == request.auth.uid;
      }
    }

    // 5. Public Hotels Catalog
    // कोई भी होटल देख सकता है (Guest included), लेकिन केवल एडमिन लिख सकता है
    match /hotels/{hotelId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## 7. Frontend & UI Integration

### 7.1 How `AuthScreen` triggers `AuthService`
जब यूज़र लॉगिन बटन पर क्लिक करता है:
```dart
Future<void> _handleEmailAuth() async {
  setState(() => _isLoading = true);
  try {
    if (_isLoginMode) {
      await AuthService.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await AuthService.instance.signUpWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );
    }
    
    // Successful Authentication
    if (mounted) {
      widget.onAuthenticated?.call();
      Navigator.of(context).pop();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AuthService.getErrorMessage(e))),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

### 7.2 Live Reactive StreamBuilder Pattern (Plans Hub)
स्क्रीन को लाइव रखने के लिए StreamBuilder का उपयोग:
```dart
StreamBuilder<List<TripPlan>>(
  stream: FirestoreService.instance.streamUserTrips(user.uid),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6F8068)));
    }
    final trips = snapshot.data ?? [];
    if (trips.isEmpty) {
      return const EmptyPlanState(title: 'No Trips Yet');
    }
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) => TripPlanCard(plan: trips[index]),
    );
  },
)
```

---

## 8. Common Viva / Interview Questions & Answers

### Q1. आपने Firebase को सीधे UI में क्यों नहीं कॉल किया? `AuthService` और `FirestoreService` क्यों बनाए?
> **उत्तर**: यह **Separation of Concerns (SoC)** और **Clean Architecture** का सिद्धांत है। अगर हम UI विगेट्स के अंदर सीधे `FirebaseFirestore.instance.collection(...)` लिखते हैं, तो कोड मेसी हो जाता है, टेस्ट करना नामुमकिन हो जाता है, और बैकएंड बदलने पर हर स्क्रीन बदलनी पड़ती है। सर्विस लेयर बनाने से सारा बिज़नेस लॉजिक एक जगह सेंट्रलाइज़्ड रहता है।

### Q2. `_db.batch()` क्या है और इसका उपयोग कहाँ किया गया है?
> **उत्तर**: `WriteBatch` कई डेटाबेस राइट ऑपरेशन्स को एक साथ एटॉमिक (Atomic) तरीक़े से निष्पादित करता है। StayEase में जब होटल बुक होता है, तो `users/{uid}/bookings/{id}` और ग्लोबल `bookings/{id}` दोनों में डेटा एक ही समय पर लिखा जाता है। अगर इंटरनेट कट जाए या कोई एरर आए, तो आधा अधूरा डेटा नहीं लिखा जाता — या तो दोनों राइट होते हैं या कोई नहीं।

### Q3. `FieldValue.serverTimestamp()` और `DateTime.now()` में क्या अंतर है?
> **उत्तर**: `DateTime.now()` क्लाइंट डिवाइस की घड़ी (Clock) का समय लेता है, जो यूज़र द्वारा ग़लत सेट किया जा सकता है। `FieldValue.serverTimestamp()` Google के Firebase सर्वर का आधिकारिक समय लेता है, जिससे डेटाबेस में हमेशा सटीक और छेड़छाड़-रहित समय रिकॉर्ड होता है।

### Q4. Phone Authentication में Android Auto-Retrieval कैसे काम करता है?
> **उत्तर**: Firebase SDK का `onVerificationCompleted` कॉलबैक Android के SMS Retriever API का उपयोग करता है। यह ऐप को यूज़र के इनपुट के बिना ही SMS पढ़कर ऑटोमैटिकली लॉगिन करवा देता है, जिससे प्रीमियम यूज़र एक्सपीरियंस मिलता है।

### Q5. Security Rules में `get(/databases/...)` का क्या रोल है?
> **उत्तर**: जब कोई यूज़र सब-कलेक्शन (जैसे `itinerary` या `tasks`) को मॉडिफाई करता है, तो `get()` फ़ंक्शन पैरेंट डॉक्यूमेंट (`plans/{planId}`) को पढ़कर चेक करता है कि क्या उस पैरेंट प्लान का `userId` करंट लॉगिन यूज़र से मैच करता है या नहीं। इससे कोई भी अनऑथराइज़्ड यूज़र किसी दूसरे के ट्रिप में टास्क नहीं जोड़ सकता।

---

**StayEase Firebase Integration Guide** — Production Grade, Clean & Maintainable.
