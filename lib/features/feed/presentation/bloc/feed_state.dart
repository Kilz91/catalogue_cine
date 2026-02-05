import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/recommendation_entity.dart';

class FeedState {
  final List<ActivityEntity> activities;
  final List<RecommendationEntity> recommendations;
  final bool isLoadingActivities;
  final bool isLoadingRecommendations;
  final String? errorMessage;

  const FeedState({
    this.activities = const [],
    this.recommendations = const [],
    this.isLoadingActivities = false,
    this.isLoadingRecommendations = false,
    this.errorMessage,
  });

  FeedState copyWith({
    List<ActivityEntity>? activities,
    List<RecommendationEntity>? recommendations,
    bool? isLoadingActivities,
    bool? isLoadingRecommendations,
    String? errorMessage,
  }) {
    return FeedState(
      activities: activities ?? this.activities,
      recommendations: recommendations ?? this.recommendations,
      isLoadingActivities: isLoadingActivities ?? this.isLoadingActivities,
      isLoadingRecommendations: isLoadingRecommendations ?? this.isLoadingRecommendations,
      errorMessage: errorMessage,
    );
  }
}
