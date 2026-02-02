/// Entité représentant la progression d'un utilisateur sur un média
class ProgressEntity {
  final String id;
  final String userId;
  final int mediaId;
  final String mediaType; // movie, tv, anime
  final int currentSeason;
  final int currentEpisode;
  final int totalEpisodes;
  final double percentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastUpdated;

  ProgressEntity({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    this.currentSeason = 0,
    this.currentEpisode = 0,
    this.totalEpisodes = 0,
    this.percentage = 0.0,
    this.startDate,
    this.endDate,
    this.lastUpdated,
  });

  ProgressEntity copyWith({
    String? id,
    String? userId,
    int? mediaId,
    String? mediaType,
    int? currentSeason,
    int? currentEpisode,
    int? totalEpisodes,
    double? percentage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastUpdated,
  }) {
    return ProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      percentage: percentage ?? this.percentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
