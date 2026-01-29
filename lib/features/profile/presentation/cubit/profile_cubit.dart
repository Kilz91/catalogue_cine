import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_state.dart';

/// Cubit pour gérer le profil utilisateur
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;

  ProfileCubit({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.uploadProfileImageUseCase,
  }) : super(ProfileInitialState());

  /// Charger le profil utilisateur
  Future<void> loadProfile() async {
    emit(ProfileLoadingState());
    try {
      final user = await getUserProfileUseCase();
      emit(ProfileLoadedState(user));
    } on AppException catch (e) {
      emit(ProfileErrorState(e.message));
    } catch (e) {
      emit(ProfileErrorState('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Mettre à jour le profil
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoadedState) {
      emit(ProfileUpdatingState(currentState.user));
    }

    try {
      final updatedUser = await updateUserProfileUseCase(
        displayName: displayName,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
      emit(ProfileLoadedState(updatedUser));
    } on AppException catch (e) {
      emit(ProfileErrorState(e.message));
      // Recharger le profil en cas d'erreur
      await loadProfile();
    } catch (e) {
      emit(ProfileErrorState('Erreur inattendue: ${e.toString()}'));
      // Recharger le profil en cas d'erreur
      await loadProfile();
    }
  }

  /// Télécharger une image de profil
  Future<void> uploadImage(String imagePath) async {
    final currentState = state;
    if (currentState is ProfileLoadedState) {
      emit(ProfileUpdatingState(currentState.user));
    }

    try {
      final imageUrl = await uploadProfileImageUseCase(imagePath);
      await updateProfile(profileImageUrl: imageUrl);
    } on AppException catch (e) {
      emit(ProfileErrorState(e.message));
      // Recharger le profil en cas d'erreur
      await loadProfile();
    } catch (e) {
      emit(ProfileErrorState('Erreur inattendue: ${e.toString()}'));
      // Recharger le profil en cas d'erreur
      await loadProfile();
    }
  }
}
