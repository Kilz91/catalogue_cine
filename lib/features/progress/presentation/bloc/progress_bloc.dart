import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/usecases/get_media_progress_usecase.dart';
import '../../domain/usecases/update_progress_usecase.dart';
import '../../../feed/domain/usecases/log_activity_usecase.dart';

part 'progress_event.dart';
part 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetMediaProgressUseCase getMediaProgressUseCase;
  final UpdateProgressUseCase updateProgressUseCase;
  final LogActivityUseCase logActivityUseCase;

  ProgressBloc({
    required this.getMediaProgressUseCase,
    required this.updateProgressUseCase,
    required this.logActivityUseCase,
  }) : super(const ProgressState()) {
    on<LoadProgressEvent>(_onLoadProgress);
    on<UpdateProgressEvent>(_onUpdateProgress);
  }

  Future<void> _onLoadProgress(
    LoadProgressEvent event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      successMessage: const _Wrapped(''),
      errorMessage: const _Wrapped(''),
    ));

    final result = await getMediaProgressUseCase.call(
      GetMediaProgressParams(
        mediaId: event.mediaId,
        mediaType: event.mediaType,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _Wrapped(failure.message),
        ),
      ),
      (progress) => emit(
        state.copyWith(
          isLoading: false,
          progress: _Wrapped(progress),
          errorMessage: const _Wrapped(''),
        ),
      ),
    );
  }

  Future<void> _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      successMessage: const _Wrapped(''),
      errorMessage: const _Wrapped(''),
    ));

    final result = await updateProgressUseCase.call(
      UpdateProgressParams(
        mediaId: event.mediaId,
        mediaType: event.mediaType,
        currentSeason: event.currentSeason,
        currentEpisode: event.currentEpisode,
        totalEpisodes: event.totalEpisodes,
        percentage: event.percentage,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _Wrapped(failure.message),
          ),
        );
      },
      (_) async {
        // Après mise à jour, recharger la progression
        final loadResult = await getMediaProgressUseCase.call(
          GetMediaProgressParams(
            mediaId: event.mediaId,
            mediaType: event.mediaType,
          ),
        );
        
        await loadResult.fold(
          (failure) async {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: _Wrapped(failure.message),
              ),
            );
          },
          (progress) async {
            // Si terminé (100%) ET validation explicite, enregistrer l'activité
            if (progress.percentage >= 100.0 && event.shouldLogActivity) {
              print('✅ Média terminé - Enregistrement de l\'activité');
              await logActivityUseCase.call(
                actionType: 'completed',
                mediaId: event.mediaId.toString(),
                mediaTitle: event.mediaTitle ?? 'Média',
                mediaPoster: event.mediaPoster ?? '',
              );
            }
            
            emit(
              state.copyWith(
                isLoading: false,
                progress: _Wrapped(progress),
                errorMessage: const _Wrapped(''),
                successMessage: const _Wrapped('Progression mise à jour'),
              ),
            );
          },
        );
      },
    );
  }
}
