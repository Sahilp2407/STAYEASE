import 'package:cloud_firestore/cloud_firestore.dart';

// ── USER MODEL: Firestore me user profile ka data structure define karne ke liye ──
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String provider;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor: UserProfile instance initialize karne ke liye
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.photoUrl = '',
    this.provider = 'password',
    required this.createdAt,
    required this.updatedAt,
  });

  // UserProfile object ko Firestore JSON Map me convert karna
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

  // Firestore DocumentSnapshot se UserProfile object parse karna
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

  // Fields update karke naya immutable instance generate karna
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? provider,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
