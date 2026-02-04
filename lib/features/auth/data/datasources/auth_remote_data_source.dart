import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../../../core/error/exceptions.dart';

/// DataSource distant pour l'authentification (Firebase)
abstract class AuthRemoteDataSource {
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<bool> isUserLoggedIn();

  Future<void> resetPassword(String email);
}

/// Implémentation avec Firebase Auth
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);

      // Créer le document utilisateur dans Firestore pour la recherche d'amis
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'displayName': displayName,
        'displayNameLower': displayName.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return User(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        profileImageUrl: userCredential.user?.photoURL,
        createdAt: DateTime.now(),
        isVerified: false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppException('Erreur d\'inscription: ${e.toString()}');
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return User(
        id: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user?.displayName,
        profileImageUrl: userCredential.user?.photoURL,
        createdAt: userCredential.user?.metadata.creationTime,
        isVerified: userCredential.user?.emailVerified ?? false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppException('Erreur de connexion: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AppException('Erreur de déconnexion: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        profileImageUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
        isVerified: user.emailVerified,
      );
    } catch (e) {
      throw AppException('Erreur lors de la récupération de l\'utilisateur');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppException('Erreur de réinitialisation: ${e.toString()}');
    }
  }

  AppException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UnauthorizedException('Utilisateur non trouvé');
      case 'wrong-password':
        return UnauthorizedException('Mot de passe incorrect');
      case 'email-already-in-use':
        return AppException('Email déjà utilisé');
      case 'weak-password':
        return AppException('Mot de passe trop faible');
      case 'invalid-email':
        return AppException('Email invalide');
      default:
        return AppException('Erreur d\'authentification: ${e.message}');
    }
  }
}
