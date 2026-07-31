import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configured for Firebase project: imhosys-web-app
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjMBgF77VHuks9hOSPKJ0fq28_dbdS3JU',
    appId: '1:1003967438591:web:7b7be7543b67a40c8eb6ca',
    messagingSenderId: '1003967438591',
    projectId: 'imhosys-web-app',
    authDomain: 'imhosys-web-app.firebaseapp.com',
    storageBucket: 'imhosys-web-app.firebasestorage.app',
    measurementId: 'G-1JBNWJTYVW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjMBgF77VHuks9hOSPKJ0fq28_dbdS3JU',
    appId: '1:1003967438591:web:7b7be7543b67a40c8eb6ca',
    messagingSenderId: '1003967438591',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjMBgF77VHuks9hOSPKJ0fq28_dbdS3JU',
    appId: '1:1003967438591:web:7b7be7543b67a40c8eb6ca',
    messagingSenderId: '1003967438591',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.firebasestorage.app',
    iosBundleId: 'com.imhosys.webapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjMBgF77VHuks9hOSPKJ0fq28_dbdS3JU',
    appId: '1:1003967438591:web:7b7be7543b67a40c8eb6ca',
    messagingSenderId: '1003967438591',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.firebasestorage.app',
    iosBundleId: 'com.imhosys.webapp',
  );
}
