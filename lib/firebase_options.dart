import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
  show defaultTargetPlatform, TargetPlatform;

/// Fichier auto-généré par Firebase CLI
/// À générer avec: flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are configured for Android and iOS only.',
        );
    }
  }

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
}