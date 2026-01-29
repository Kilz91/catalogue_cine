import '../entities/user.dart';

/// UseCase abstrait pour les opérations d'authentification
abstract class AuthRepository {
  /// Enregistrer un nouvel utilisateur
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Connexion utilisateur
  Future<User> login({required String email, required String password});

  /// Déconnexion
  Future<void> logout();

  /// Récupérer l'utilisateur actuel
  Future<User?> getCurrentUser();

  /// Vérifier si utilisateur authentifié
  Future<bool> isUserLoggedIn();

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email);
}
