import '../repositories/profile_repository.dart';
import '../../../auth/domain/entities/user.dart';

/// UseCase pour récupérer le profil utilisateur
class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<User> call() {
    return repository.getUserProfile();
  }
}

/// UseCase pour mettre à jour le profil
class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<User> call({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      bio: bio,
      profileImageUrl: profileImageUrl,
    );
  }
}

/// UseCase pour télécharger une image de profil
class UploadProfileImageUseCase {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<String> call(String imagePath) {
    return repository.uploadProfileImage(imagePath);
  }
}
