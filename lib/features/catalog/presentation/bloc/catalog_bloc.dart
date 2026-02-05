import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../feed/domain/usecases/log_activity_usecase.dart';
import '../../domain/usecases/catalog_usecases.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final SearchMediaUseCase searchMediaUseCase;
  final GetUserCatalogUseCase getUserCatalogUseCase;
  final AddToCatalogUseCase addToCatalogUseCase;
  final UpdateCatalogStatusUseCase updateCatalogStatusUseCase;
  final RemoveFromCatalogUseCase removeFromCatalogUseCase;
  final LogActivityUseCase logActivityUseCase;

  CatalogBloc({
    required this.searchMediaUseCase,
    required this.getUserCatalogUseCase,
    required this.addToCatalogUseCase,
    required this.updateCatalogStatusUseCase,
    required this.removeFromCatalogUseCase,
    required this.logActivityUseCase,
  }) : super(const CatalogState()) {
    on<LoadCatalogEvent>(_onLoadCatalog);
    on<SearchMediaEvent>(_onSearchMedia);
    on<ClearSearchEvent>(_onClearSearch);
    on<AddToCatalogEvent>(_onAddToCatalog);
    on<UpdateCatalogStatusEvent>(_onUpdateStatus);
    on<RemoveFromCatalogEvent>(_onRemoveFromCatalog);
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, error: null, statusFilter: event.status),
    );
    try {
      final catalog = await getUserCatalogUseCase(status: event.status);
      emit(state.copyWith(isLoading: false, catalog: catalog));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSearchMedia(
    SearchMediaEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, searchType: event.type));
    try {
      final results = await searchMediaUseCase(
        query: event.query,
        type: event.type,
      );
      emit(state.copyWith(isLoading: false, searchResults: results));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<CatalogState> emit) {
    emit(state.copyWith(searchResults: const [], error: null));
  }

  Future<void> _onAddToCatalog(
    AddToCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addToCatalogUseCase(media: event.media, status: event.status);
      // Logger l'activité selon le statut
      final actionType = event.status == 'watching' 
          ? 'started' 
          : event.status == 'planned' 
              ? 'planned' 
              : null;

      if (actionType != null) {
        // Construire l'URL complète du poster
        final posterUrl = event.media.posterPath != null && event.media.posterPath!.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500${event.media.posterPath}'
            : '';

        await logActivityUseCase.call(
          actionType: actionType,
          mediaId: event.media.id.toString(),
          mediaTitle: event.media.title,
          mediaPoster: posterUrl,
        );
      }
      
      final catalog = await getUserCatalogUseCase(status: state.statusFilter);
      emit(state.copyWith(isLoading: false, catalog: catalog));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateCatalogStatusEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateCatalogStatusUseCase(
        userMediaId: event.userMediaId,
        status: event.status,
      );
      final catalog = await getUserCatalogUseCase(status: state.statusFilter);
      emit(state.copyWith(isLoading: false, catalog: catalog));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRemoveFromCatalog(
    RemoveFromCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await removeFromCatalogUseCase(event.userMediaId);
      final catalog = await getUserCatalogUseCase(status: state.statusFilter);
      emit(state.copyWith(isLoading: false, catalog: catalog));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
