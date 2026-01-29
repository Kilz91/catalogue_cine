import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Implémentation du repository profil
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }

  @override
  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    return await remoteDataSource.updateProfile(
      displayName: displayName,
      bio: bio,
      profileImageUrl: profileImageUrl,
    );
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    return await remoteDataSource.uploadProfileImage(imagePath);
  }
}
