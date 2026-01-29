/// Entité Media (film, série ou animé)
class Media {
  final int id;
  final String title;
  final String type; // 'movie', 'tv', 'anime'
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final DateTime? releaseDate;
  final List<String> genres;
  final double? voteAverage;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  Media({
    required this.id,
    required this.title,
    required this.type,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.genres = const [],
    this.voteAverage,
    this.numberOfSeasons,
    this.numberOfEpisodes,
  });

  // Méthode pour créer une copie avec modifications
  Media copyWith({
    int? id,
    String? title,
    String? type,
    String? posterPath,
    String? backdropPath,
    String? overview,
    DateTime? releaseDate,
    List<String>? genres,
    double? voteAverage,
    int? numberOfSeasons,
    int? numberOfEpisodes,
  }) {
    return Media(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      voteAverage: voteAverage ?? this.voteAverage,
      numberOfSeasons: numberOfSeasons ?? this.numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes ?? this.numberOfEpisodes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Media && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
