import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/actor_usecases.dart';
import 'actor_event.dart';
import 'actor_state.dart';

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}

/// BLoC pour gérer les acteurs
class ActorBloc extends Bloc<ActorEvent, ActorState> {
  final GetActorDetailsUseCase getActorDetailsUseCase;
  final GetActorCreditsUseCase getActorCreditsUseCase;
  final GetMediaCastUseCase getMediaCastUseCase;

  ActorBloc({
    required this.getActorDetailsUseCase,
    required this.getActorCreditsUseCase,
    required this.getMediaCastUseCase,
  }) : super(const ActorInitialState()) {
    on<LoadActorDetailsEvent>(_onLoadActorDetails);
    on<LoadActorCreditsEvent>(_onLoadActorCredits);
    on<LoadMediaCastEvent>(_onLoadMediaCast);
    on<ResetActorEvent>(_onReset);
  }

  Future<void> _onLoadActorDetails(
    LoadActorDetailsEvent event,
    Emitter<ActorState> emit,
  ) async {
    emit(const ActorLoadingState());
    try {
      final actor = await getActorDetailsUseCase(event.actorId);
      emit(ActorDetailsLoadedState(actor));
    } catch (e) {
      emit(ActorErrorState('Erreur lors du chargement de l\'acteur: $e'));
    }
  }

  Future<void> _onLoadActorCredits(
    LoadActorCreditsEvent event,
    Emitter<ActorState> emit,
  ) async {
    emit(const ActorLoadingState());
    try {
      final actor = await getActorDetailsUseCase(event.actorId);
      final credits = await getActorCreditsUseCase(event.actorId);
      emit(ActorCreditsLoadedState(actor: actor, credits: credits));
    } catch (e) {
      emit(ActorErrorState('Erreur lors du chargement de la filmographie: $e'));
    }
  }

  Future<void> _onLoadMediaCast(
    LoadMediaCastEvent event,
    Emitter<ActorState> emit,
  ) async {
    emit(const ActorLoadingState());
    try {
      final cast = await getMediaCastUseCase(
        mediaId: event.mediaId,
        mediaType: event.mediaType,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout lors du chargement du cast');
        },
      );
      // Même si la liste est vide, on émet un état de succès
      emit(MediaCastLoadedState(cast));
    } on TimeoutException catch (e) {
      emit(ActorErrorState('Temps limite dépassé: ${e.message}'));
    } catch (e) {
      emit(ActorErrorState('Erreur lors du chargement du cast: $e'));
    }
  }

  void _onReset(ResetActorEvent event, Emitter<ActorState> emit) {
    emit(const ActorInitialState());
  }
}
