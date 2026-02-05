import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feed_activities_usecase.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import 'feed_event.dart';
import 'feed_state.dart';

/// BLoC pour la gestion du feed
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedActivitiesUseCase getFeedActivities;
  final GetRecommendationsUseCase getRecommendations;

  FeedBloc({
    required this.getFeedActivities,
    required this.getRecommendations,
  }) : super(const FeedState()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LoadRecommendationsEvent>(_onLoadRecommendations);
    on<RefreshFeedEvent>(_onRefreshFeed);
  }

  Future<void> _onLoadFeed(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(isLoadingActivities: true, errorMessage: null));

    final result = await getFeedActivities();

    result.fold(
      (failure) {
        print('❌ FEED LOAD ERROR: ${failure.message}');
        emit(state.copyWith(
          isLoadingActivities: false,
          errorMessage: failure.message,
        ));
      },
      (activities) {
        print('✅ FEED LOADED: ${activities.length} activités');
        emit(state.copyWith(
          isLoadingActivities: false,
          activities: activities,
        ));
      },
    );
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendationsEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(isLoadingRecommendations: true));

    final result = await getRecommendations();

    result.fold(
      (failure) {
        print('❌ RECOMMENDATIONS ERROR: ${failure.message}');
        emit(state.copyWith(
          isLoadingRecommendations: false,
          errorMessage: failure.message,
        ));
      },
      (recommendations) {
        print('✅ RECOMMENDATIONS LOADED: ${recommendations.length} recommandations');
        emit(state.copyWith(
          isLoadingRecommendations: false,
          recommendations: recommendations,
        ));
      },
    );
  }

  Future<void> _onRefreshFeed(
    RefreshFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    await _onLoadFeed(LoadFeedEvent(), emit);
    await _onLoadRecommendations(LoadRecommendationsEvent(), emit);
  }
}
