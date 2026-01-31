import '../../domain/entities/actor.dart';
import '../../../catalog/domain/entities/media.dart';

/// States pour ActorBloc
abstract class ActorState {
  const ActorState();
}

/// État initial
class ActorInitialState extends ActorState {
  const ActorInitialState();
}

/// État de chargement
class ActorLoadingState extends ActorState {
  const ActorLoadingState();
}

/// Détails de l'acteur chargés
class ActorDetailsLoadedState extends ActorState {
  final Actor actor;

  const ActorDetailsLoadedState(this.actor);
}

/// Filmographie chargée
class ActorCreditsLoadedState extends ActorState {
  final Actor actor;
  final List<Media> credits;

  const ActorCreditsLoadedState({
    required this.actor,
    required this.credits,
  });
}

/// Cast d'un média chargé
class MediaCastLoadedState extends ActorState {
  final List<Actor> cast;

  const MediaCastLoadedState(this.cast);
}

/// État d'erreur
class ActorErrorState extends ActorState {
  final String message;

  const ActorErrorState(this.message);
}
