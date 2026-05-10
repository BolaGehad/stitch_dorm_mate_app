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
    apiKey: 'AIzaSyCLZv_4ZBfgJaXS1fr_9v_JncLBHUmjqQI',
    appId: '1:1083899114977:web:aacc42be492e70a0480ea0',
    messagingSenderId: '1083899114977',
    projectId: 'dorm-mate-ed237',
    authDomain: 'dorm-mate-ed237.firebaseapp.com',
    storageBucket: 'dorm-mate-ed237.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJy5piCdUUuhrZCR04K5Fuqy4aQis0b5E',
    appId: '1:1083899114977:android:6efd4bfe53a9a362480ea0',
    messagingSenderId: '1083899114977',
    projectId: 'dorm-mate-ed237',
    storageBucket: 'dorm-mate-ed237.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAu4gAzq9B0_Mbox8-ucp69XdvoJPgAC5Y',
    appId: '1:1083899114977:ios:7e67469ec343fec9480ea0',
    messagingSenderId: '1083899114977',
    projectId: 'dorm-mate-ed237',
    storageBucket: 'dorm-mate-ed237.firebasestorage.app',
    iosBundleId: 'com.example.dormMate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAu4gAzq9B0_Mbox8-ucp69XdvoJPgAC5Y',
    appId: '1:1083899114977:ios:7e67469ec343fec9480ea0',
    messagingSenderId: '1083899114977',
    projectId: 'dorm-mate-ed237',
    storageBucket: 'dorm-mate-ed237.firebasestorage.app',
    iosBundleId: 'com.example.dormMate',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCLZv_4ZBfgJaXS1fr_9v_JncLBHUmjqQI',
    appId: '1:1083899114977:web:f89d2bfaf50350a7480ea0',
    messagingSenderId: '1083899114977',
    projectId: 'dorm-mate-ed237',
    authDomain: 'dorm-mate-ed237.firebaseapp.com',
    storageBucket: 'dorm-mate-ed237.firebasestorage.app',
  );
}
