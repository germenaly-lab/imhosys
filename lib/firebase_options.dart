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
    apiKey: 'AIzaSyA_IMHOSYS_WEB_APP_FIREBASE_KEY',
    appId: '1:543210987654:web:imhosyswebapp0123456',
    messagingSenderId: '543210987654',
    projectId: 'imhosys-web-app',
    authDomain: 'imhosys-web-app.firebaseapp.com',
    storageBucket: 'imhosys-web-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_IMHOSYS_WEB_APP_ANDROID_KEY',
    appId: '1:543210987654:android:imhosyswebapp0123456',
    messagingSenderId: '543210987654',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_IMHOSYS_WEB_APP_IOS_KEY',
    appId: '1:543210987654:ios:imhosyswebapp0123456',
    messagingSenderId: '543210987654',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.appspot.com',
    iosBundleId: 'com.imhosys.webapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_IMHOSYS_WEB_APP_MACOS_KEY',
    appId: '1:543210987654:ios:imhosyswebapp0123456',
    messagingSenderId: '543210987654',
    projectId: 'imhosys-web-app',
    storageBucket: 'imhosys-web-app.appspot.com',
    iosBundleId: 'com.imhosys.webapp',
  );
}
