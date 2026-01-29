import '../../../auth/domain/entities/user.dart';

/// États pour le profil utilisateur
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final User user;
  ProfileLoadedState(this.user);
}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState(this.message);
}

class ProfileUpdatingState extends ProfileState {
  final User currentUser;
  ProfileUpdatingState(this.currentUser);
}
