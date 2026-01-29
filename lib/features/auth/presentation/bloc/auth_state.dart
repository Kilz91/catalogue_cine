import '../../domain/entities/user.dart';

/// États pour l'authentification
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final User user;
  AuthSuccessState(this.user);
}

class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}

class AuthLoggedOutState extends AuthState {}

class AuthUnauthenticatedState extends AuthState {}
