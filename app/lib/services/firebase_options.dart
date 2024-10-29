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
    apiKey: 'AIzaSyCZhDMAF_pr7b72pGoJMWkdOJFQAH6z7WU',
    appId: '1:578103725527:web:3db1478a2d62d2deb24f92',
    messagingSenderId: '578103725527',
    projectId: 'app-flutter-2cd8b',
    authDomain: 'app-flutter-2cd8b.firebaseapp.com',
    storageBucket: 'app-flutter-2cd8b.appspot.com',
    measurementId: 'G-ZZN02YQ82V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYtwOFmVjoysUaAtYkl8N7JC70H-6LVYU',
    appId: '1:578103725527:android:70d6c1e277a2b27ab24f92',
    messagingSenderId: '578103725527',
    projectId: 'app-flutter-2cd8b',
    storageBucket: 'app-flutter-2cd8b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6f-yMdMLTDu9mCpcgHD2WXqv-1od4bN0',
    appId: '1:578103725527:ios:d628ec5731c75b35b24f92',
    messagingSenderId: '578103725527',
    projectId: 'app-flutter-2cd8b',
    storageBucket: 'app-flutter-2cd8b.appspot.com',
    iosBundleId: 'com.educadev.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA6f-yMdMLTDu9mCpcgHD2WXqv-1od4bN0',
    appId: '1:578103725527:ios:d628ec5731c75b35b24f92',
    messagingSenderId: '578103725527',
    projectId: 'app-flutter-2cd8b',
    storageBucket: 'app-flutter-2cd8b.appspot.com',
    iosBundleId: 'com.educadev.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZhDMAF_pr7b72pGoJMWkdOJFQAH6z7WU',
    appId: '1:578103725527:web:45310a8ee1a26c5eb24f92',
    messagingSenderId: '578103725527',
    projectId: 'app-flutter-2cd8b',
    authDomain: 'app-flutter-2cd8b.firebaseapp.com',
    storageBucket: 'app-flutter-2cd8b.appspot.com',
    measurementId: 'G-5F9PJDWPTW',
  );
}
