import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Fichier auto-généré par Firebase CLI
/// À générer avec: flutterfire configure
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
    apiKey: 'AIzaSyA5cM8TnukXCe6TtqUl5mokWatW4UacP4s',
    appId: '1:311611942894:web:f74a739145be5123fc10ff',
    messagingSenderId: '311611942894',
    projectId: 'catalogue-cine',
    authDomain: 'catalogue-cine.firebaseapp.com',
    storageBucket: 'catalogue-cine.firebasestorage.app',
    measurementId: 'G-D55S3L7WX8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHaRrKOSbaIEnJGC87PsqlhpZFp4ilLRw',
    appId: '1:311611942894:android:d44cae0b407be4fbfc10ff',
    messagingSenderId: '311611942894',
    projectId: 'catalogue-cine',
    storageBucket: 'catalogue-cine.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAq7Kq4mDcidqyWRfSkHNrFW2pLCTXI5ek',
    appId: '1:311611942894:ios:82c313be136a2456fc10ff',
    messagingSenderId: '311611942894',
    projectId: 'catalogue-cine',
    storageBucket: 'catalogue-cine.firebasestorage.app',
    iosBundleId: 'com.example.catalogueCine',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAq7Kq4mDcidqyWRfSkHNrFW2pLCTXI5ek',
    appId: '1:311611942894:ios:82c313be136a2456fc10ff',
    messagingSenderId: '311611942894',
    projectId: 'catalogue-cine',
    storageBucket: 'catalogue-cine.firebasestorage.app',
    iosBundleId: 'com.example.catalogueCine',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA5cM8TnukXCe6TtqUl5mokWatW4UacP4s',
    appId: '1:311611942894:web:d0e84a5d6b9de577fc10ff',
    messagingSenderId: '311611942894',
    projectId: 'catalogue-cine',
    authDomain: 'catalogue-cine.firebaseapp.com',
    storageBucket: 'catalogue-cine.firebasestorage.app',
    measurementId: 'G-0KJDMFBFDE',
  );

}