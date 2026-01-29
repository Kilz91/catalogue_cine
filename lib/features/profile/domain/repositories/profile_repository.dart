import '../../../auth/domain/entities/user.dart';

/// Repository abstrait pour le profil utilisateur
abstract class ProfileRepository {
  /// Récupérer le profil de l'utilisateur connecté
  Future<User> getUserProfile();

  /// Mettre à jour le profil utilisateur
  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  });

  /// Télécharger une image de profil
  Future<String> uploadProfileImage(String imagePath);
}
