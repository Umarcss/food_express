// File generated for the Food Express Firebase project.
// To regenerate later, run:
// flutterfire configure --project=food-express-ea811 --platforms=android,web

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDu2oxYEkjdswvOQoN-CZRusbyn8jvB4PE',
    appId: '1:87725343175:web:f3aa691b1395004cefd9e2',
    messagingSenderId: '87725343175',
    projectId: 'food-express-ea811',
    authDomain: 'food-express-ea811.firebaseapp.com',
    storageBucket: 'food-express-ea811.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUmBoFieEsEnK8zBnD-mjY-IlLKsosuYU',
    appId: '1:87725343175:android:03e6c353177b36baefd9e2',
    messagingSenderId: '87725343175',
    projectId: 'food-express-ea811',
    storageBucket: 'food-express-ea811.firebasestorage.app',
  );
}
