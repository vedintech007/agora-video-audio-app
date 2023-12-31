// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAMEvz-cKbcw8uQtAnU7Yg6_1wX3RizST8',
    appId: '1:261889285594:web:93aeacd99f0c469cc974e3',
    messagingSenderId: '261889285594',
    projectId: 'agora-call-app',
    authDomain: 'agora-call-app.firebaseapp.com',
    storageBucket: 'agora-call-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmdvVJ4Qu5-JJPtnjFMPKRaGW1nh3Iy5s',
    appId: '1:261889285594:android:a7478ba8f62ee940c974e3',
    messagingSenderId: '261889285594',
    projectId: 'agora-call-app',
    storageBucket: 'agora-call-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZOgJLk1tEkW6hzp4-HU8JQQVDTpa12y8',
    appId: '1:261889285594:ios:03613e842c17cedbc974e3',
    messagingSenderId: '261889285594',
    projectId: 'agora-call-app',
    storageBucket: 'agora-call-app.appspot.com',
    iosBundleId: 'com.codeconline.agoraCalling',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAZOgJLk1tEkW6hzp4-HU8JQQVDTpa12y8',
    appId: '1:261889285594:ios:b90d6c23565a6191c974e3',
    messagingSenderId: '261889285594',
    projectId: 'agora-call-app',
    storageBucket: 'agora-call-app.appspot.com',
    iosBundleId: 'com.codeconline.agoraCalling.RunnerTests',
  );
}
