import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured {
    final options = currentPlatform;
    return options.apiKey.isNotEmpty &&
        options.appId.isNotEmpty &&
        options.messagingSenderId.isNotEmpty &&
        options.projectId.isNotEmpty;
  }

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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBMLQGXVSLfBBEX-_NFoHCplLkbFJBuWG4',
    appId: '1:50978109157:web:1406f56adb66d5f09c860c',
    messagingSenderId: '50978109157',
    projectId: 'baby-bloom-app',
    authDomain: 'baby-bloom-app.firebaseapp.com',
    storageBucket: 'baby-bloom-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXtFfXll9lWQn48-VtPepU6G-XT6rZajw',
    appId: '1:50978109157:android:3b6f335adc88dd2d9c860c',
    messagingSenderId: '50978109157',
    projectId: 'baby-bloom-app',
    storageBucket: 'baby-bloom-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdpzJrY6Qf_m8ZZQEl5umY1LS2V6Ow7WI',
    appId: '1:50978109157:ios:883ae061736686989c860c',
    messagingSenderId: '50978109157',
    projectId: 'baby-bloom-app',
    storageBucket: 'baby-bloom-app.firebasestorage.app',
    iosBundleId: 'com.example.babybloom',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdpzJrY6Qf_m8ZZQEl5umY1LS2V6Ow7WI',
    appId: '1:50978109157:ios:883ae061736686989c860c',
    messagingSenderId: '50978109157',
    projectId: 'baby-bloom-app',
    storageBucket: 'baby-bloom-app.firebasestorage.app',
    iosBundleId: 'com.example.babybloom',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBMLQGXVSLfBBEX-_NFoHCplLkbFJBuWG4',
    appId: '1:50978109157:web:ba2fbc5919f40fef9c860c',
    messagingSenderId: '50978109157',
    projectId: 'baby-bloom-app',
    authDomain: 'baby-bloom-app.firebaseapp.com',
    storageBucket: 'baby-bloom-app.firebasestorage.app',
  );
}
