import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/catalog_usecases.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final SearchMediaUseCase searchMediaUseCase;
  final GetUserCatalogUseCase getUserCatalogUseCase;
  final AddToCatalogUseCase addToCatalogUseCase;
  final UpdateCatalogStatusUseCase updateCatalogStatusUseCase;
  final RemoveFromCatalogUseCase removeFromCatalogUseCase;

  CatalogBloc({
    required this.searchMediaUseCase,
    required this.getUserCatalogUseCase,
    required this.addToCatalogUseCase,
    required this.updateCatalogStatusUseCase,
    required this.removeFromCatalogUseCase,
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
