// File generated for StayEase Firebase project: stayease-app-e760b
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCAECUklot9hgKM0f8r79lXumGZpZL09a8',
    appId: '1:1020746309841:web:57abfeeada3e7e5aa0a5f0',
    messagingSenderId: '1020746309841',
    projectId: 'stayease-app-e760b',
    authDomain: 'stayease-app-e760b.firebaseapp.com',
    storageBucket: 'stayease-app-e760b.firebasestorage.app',
    measurementId: 'G-L4LYV4SX4W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPWJYOO8FyeywQAff8Pj8OJNwrzfeDMBM',
    appId: '1:1020746309841:android:43b7020a9fb22330a0a5f0',
    messagingSenderId: '1020746309841',
    projectId: 'stayease-app-e760b',
    storageBucket: 'stayease-app-e760b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDl0P3PJGHI8JJn3xgY3FnFv-xPaqX7EJA',
    appId: '1:1020746309841:ios:3a8db09132ef1d5ba0a5f0',
    messagingSenderId: '1020746309841',
    projectId: 'stayease-app-e760b',
    storageBucket: 'stayease-app-e760b.firebasestorage.app',
    iosBundleId: 'com.stayease.stayease',
  );
}
