import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implémentation du repository auth
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await remoteDataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<User> login({required String email, required String password}) async {
    return await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await remoteDataSource.isUserLoggedIn();
  }

  @override
  Future<void> resetPassword(String email) async {
    return await remoteDataSource.resetPassword(email);
  }
}
