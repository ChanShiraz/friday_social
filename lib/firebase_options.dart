// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrsi6meyTzTbUnZrqj4z5vySCqHBwAMF8',
    appId: '1:713993743774:android:54a1bbda2232d5a0b37a8f',
    messagingSenderId: '713993743774',
    projectId: 'fs-admin-b04d6',
    storageBucket: 'fs-admin-b04d6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARbjAowjcn8jWipwgoLzF2jm2VfAikiHw',
    appId: '1:713993743774:ios:27d8544348b7eb29b37a8f',
    messagingSenderId: '713993743774',
    projectId: 'fs-admin-b04d6',
    storageBucket: 'fs-admin-b04d6.firebasestorage.app',
    iosBundleId: 'com.example.fsAdmin',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDTci_cJcNf-yxUtzGpX8UnnKIpI2K-QE4',
    appId: '1:713993743774:web:af32324925e43fddb37a8f',
    messagingSenderId: '713993743774',
    projectId: 'fs-admin-b04d6',
    authDomain: 'fs-admin-b04d6.firebaseapp.com',
    storageBucket: 'fs-admin-b04d6.firebasestorage.app',
  );
}
