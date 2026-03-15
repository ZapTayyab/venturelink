// THIS FILE IS A PLACEHOLDER.
// Generate it by running:
//   flutterfire configure --project=your-firebase-dev-project
//
// It will be auto-generated with your real Firebase config values.
// DO NOT commit real API keys to git - use .gitignore.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
    apiKey: 'AIzaSyATm8BBdp3wMg36nc6gMApcc_jRUE6rJn4',
    appId: '1:1042264372635:web:2e6e4045fa0ce82d591d3e',
    messagingSenderId: '1042264372635',
    projectId: 'venturelink-dev',
    authDomain: 'venturelink-dev.firebaseapp.com',
    storageBucket: 'venturelink-dev.firebasestorage.app',
    measurementId: 'G-XBW18PPVQB',
  );

  // REPLACE THESE with your actual values from Firebase Console

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAThU6LmnMwta98ZRWfnD34jgnHIy9596A',
    appId: '1:1042264372635:android:10b27d949127bea7591d3e',
    messagingSenderId: '1042264372635',
    projectId: 'venturelink-dev',
    storageBucket: 'venturelink-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'venturelink-dev',
    storageBucket: 'venturelink-dev.appspot.com',
    iosBundleId: 'com.venturelink.app',
  );
}