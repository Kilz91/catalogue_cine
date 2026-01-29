import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notifier pour écouter les changements d'état d'authentification
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _subscription;

  AuthNotifier(this._firebaseAuth) {
    _subscription = _firebaseAuth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
