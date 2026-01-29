/// Entité pour la progression sur un média
class Progress {
  final String id;
  final String userMediaId;
  final int? currentSeason; // Pour les séries
  final int? currentEpisode; // Pour les séries
  final double? percentage; // 0-100 pour les films
  final DateTime? lastUpdated;

  Progress({
    required this.id,
    required this.userMediaId,
    this.currentSeason,
    this.currentEpisode,
    this.percentage,
    this.lastUpdated,
  });

  Progress copyWith({
    String? id,
    String? userMediaId,
    int? currentSeason,
    int? currentEpisode,
    double? percentage,
    DateTime? lastUpdated,
  }) {
    return Progress(
      id: id ?? this.id,
      userMediaId: userMediaId ?? this.userMediaId,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      percentage: percentage ?? this.percentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progress && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
