import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

// ── AUTH SERVICE: पूरे ऐप में यूजर लॉगिन, रजिस्ट्रेशन और ऑथेंटिकेशन संभालने के लिए ──
class AuthService {
  // पूरे ऐप में सिर्फ 1 इंस्टेंस रखने के लिए Singleton पैटर्न
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  // Firebase Auth SDK का इंस्टेंस
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In क्लाइंट कॉन्फ़िगरेशन
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '1020746309841-i82a6m1b2rgrqn0euor9i61q9udm09vg.apps.googleusercontent.com',
  );

  // करंट लॉग्ड-इन यूजर प्राप्त करने के लिए
  User? get currentUser => _auth.currentUser;

  // यूजर के लॉगिन/लॉगआउट की रियल-टाइम स्टेट स्ट्रीम
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── 1. EMAIL & PASSWORD LOGIN: ईमेल और पासवर्ड से यूजर को लॉगिन करने के लिए ──
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
        try {
          // लॉगिन के बाद यूजर प्रोफाइल को Firestore में सिंक करना
          await FirestoreService.instance.ensureUserProfile(
            uid: cred.user!.uid,
            name: cred.user!.displayName ?? 'StayEase Guest',
            email: cred.user!.email ?? email.trim(),
            phone: cred.user!.phoneNumber ?? '',
            provider: 'password',
          ).timeout(const Duration(seconds: 4));
        } catch (e) {
          debugPrint('ensureUserProfile sync note: $e');
        }
      }
      return cred;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  // ── 2. EMAIL & PASSWORD REGISTRATION: नए यूजर का अकाउंट बनाने और प्रोफाइल सेव करने के लिए ──
  Future<UserCredential> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (cred.user != null) {
        try {
          // Firebase Auth प्रोफाइल में नाम अपडेट करना
          await cred.user!.updateDisplayName(name.trim());
          // Firestore डेटाबेस में नया यूजर डॉक्यूमेंट बनाना
          await FirestoreService.instance.createUserProfile(
            uid: cred.user!.uid,
            name: name.trim(),
            email: email.trim(),
            phone: phone ?? '',
            provider: 'password',
          ).timeout(const Duration(seconds: 4));
        } catch (e) {
          debugPrint('createUserProfile sync note: $e');
        }
      }
      return cred;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  // ── 3. GOOGLE SIGN-IN: 1-क्लिक गूगल लॉगिन (Mobile + Web दोनों के लिए) ──
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // वेब ब्राउज़र पर Google Popup के ज़रिए लॉगिन करना
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final cred = await _auth.signInWithPopup(googleProvider);
        if (cred.user != null) {
          try {
            await FirestoreService.instance.ensureUserProfile(
              uid: cred.user!.uid,
              name: cred.user!.displayName ?? 'Google Guest',
              email: cred.user!.email ?? '',
              phone: cred.user!.phoneNumber ?? '',
              photoUrl: cred.user!.photoURL ?? '',
              provider: 'google.com',
            ).timeout(const Duration(seconds: 4));
          } catch (e) {
            debugPrint('ensureUserProfile sync note: $e');
          }
        }
        return cred;
      } else {
        // मोबाइल (Android/iOS) पर नेटिव Google डायलॉग से लॉगिन करना
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null; // यूजर ने कैंसिल कर दिया
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Google टोकन्स से क्रेडेंशियल बनाकर Firebase में साइन-इन करना
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final cred = await _auth.signInWithCredential(credential);
        if (cred.user != null) {
          try {
            await FirestoreService.instance.ensureUserProfile(
              uid: cred.user!.uid,
              name: cred.user!.displayName ?? googleUser.displayName ?? 'Google Guest',
              email: cred.user!.email ?? googleUser.email,
              phone: cred.user!.phoneNumber ?? '',
              photoUrl: cred.user!.photoURL ?? googleUser.photoUrl ?? '',
              provider: 'google.com',
            ).timeout(const Duration(seconds: 4));
          } catch (e) {
            debugPrint('ensureUserProfile sync note: $e');
          }
        }
        return cred;
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.toString(),
      );
    }
  }

  // ── 4. PHONE OTP SEND: यूजर के मोबाइल नंबर पर 6-अंकों का SMS OTP भेजने के लिए ──
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException exception) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onVerificationFailed(
        FirebaseAuthException(
          code: 'phone-verification-failed',
          message: e.toString(),
        ),
      );
    }
  }

  // ── 5. CONFIRM PHONE OTP: यूजर द्वारा डाले गए OTP को वेरिफाई करके लॉगिन करने के लिए ──
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        try {
          await FirestoreService.instance.ensureUserProfile(
            uid: cred.user!.uid,
            name: cred.user!.displayName ?? 'Phone Guest',
            email: cred.user!.email ?? '',
            phone: cred.user!.phoneNumber ?? '',
            provider: 'phone',
          ).timeout(const Duration(seconds: 4));
        } catch (e) {
          debugPrint('ensureUserProfile note: $e');
        }
      }
      return cred;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'invalid-verification-code',
        message: e.toString(),
      );
    }
  }

  // ── 6. PASSWORD RESET: ईमेल पर पासवर्ड रीसेट लिंक भेजने के लिए ──
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'reset-email-failed',
        message: e.toString(),
      );
    }
  }

  // ── 7. SIGN OUT: Firebase और Google दोनों से यूजर को लॉगआउट करने के लिए ──
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  // ── 8. ERROR MAPPER: Firebase के तकनीकी एरर कोड्स को आसान हिंदी/इंग्लिश में बदलने के लिए ──
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
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'invalid-verification-code':
          return 'The verification code entered is invalid. Please check and try again.';
        case 'session-expired':
          return 'The verification code has expired. Please request a new OTP.';
        case 'invalid-phone-number':
          return 'Please enter a valid phone number with country code (e.g. +91).';
        default:
          return error.message ?? 'An unexpected authentication error occurred.';
      }
    }
    return error.toString();
  }
}
