import '../repositories/auth_repository.dart';

/// UseCase pour l'inscription
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<dynamic> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

/// UseCase pour la connexion
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<dynamic> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}

/// UseCase pour la déconnexion
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}

/// UseCase pour récupérer l'utilisateur actuel
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<dynamic> call() {
    return repository.getCurrentUser();
  }
}

/// UseCase pour vérifier si utilisateur authentifié
class IsUserLoggedInUseCase {
  final AuthRepository repository;

  IsUserLoggedInUseCase(this.repository);

  Future<bool> call() {
    return repository.isUserLoggedIn();
  }
}

/// UseCase pour réinitialiser le mot de passe
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.resetPassword(email);
  }
}
