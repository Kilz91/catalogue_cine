/// Events pour ActorBloc
abstract class ActorEvent {
  const ActorEvent();
}

/// Charger les détails d'un acteur
class LoadActorDetailsEvent extends ActorEvent {
  final int actorId;

  const LoadActorDetailsEvent(this.actorId);
}

/// Charger la filmographie d'un acteur
class LoadActorCreditsEvent extends ActorEvent {
  final int actorId;

  const LoadActorCreditsEvent(this.actorId);
}

/// Charger le cast d'un média
class LoadMediaCastEvent extends ActorEvent {
  final int mediaId;
  final String mediaType;

  const LoadMediaCastEvent({
    required this.mediaId,
    required this.mediaType,
  });
}

/// Réinitialiser l'état
class ResetActorEvent extends ActorEvent {
  const ResetActorEvent();
}
