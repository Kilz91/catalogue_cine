import '../../domain/entities/media.dart';

/// Modèle Media pour la couche data
class MediaModel {
  final int id;
  final String title;
  final String type; // movie | tv | anime
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final DateTime? releaseDate;
  final List<String> genres;
  final double? voteAverage;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  MediaModel({
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

  factory MediaModel.fromTmdbJson(Map<String, dynamic> json, String type) {
    final title = json['title'] ?? json['name'] ?? '';
    final releaseDateRaw = json['release_date'] ?? json['first_air_date'];
    return MediaModel(
      id: json['id'] ?? 0,
      title: title,
      type: type,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      releaseDate:
          releaseDateRaw != null && releaseDateRaw.toString().isNotEmpty
          ? DateTime.tryParse(releaseDateRaw)
          : null,
      genres: const [],
      voteAverage: (json['vote_average'] is num)
          ? (json['vote_average'] as num).toDouble()
          : null,
      numberOfSeasons: json['number_of_seasons'],
      numberOfEpisodes: json['number_of_episodes'],
    );
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'movie',
      posterPath: json['posterPath'],
      backdropPath: json['backdropPath'],
      overview: json['overview'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'])
          : null,
      genres: (json['genres'] as List?)?.cast<String>() ?? const [],
      voteAverage: (json['voteAverage'] is num)
          ? (json['voteAverage'] as num).toDouble()
          : null,
      numberOfSeasons: json['numberOfSeasons'],
      numberOfEpisodes: json['numberOfEpisodes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'releaseDate': releaseDate?.toIso8601String(),
      'genres': genres,
      'voteAverage': voteAverage,
      'numberOfSeasons': numberOfSeasons,
      'numberOfEpisodes': numberOfEpisodes,
    };
  }

  Media toEntity() {
    return Media(
      id: id,
      title: title,
      type: type,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genres: genres,
      voteAverage: voteAverage,
      numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes,
    );
  }

  factory MediaModel.fromEntity(Media media) {
    return MediaModel(
      id: media.id,
      title: media.title,
      type: media.type,
      posterPath: media.posterPath,
      backdropPath: media.backdropPath,
      overview: media.overview,
      releaseDate: media.releaseDate,
      genres: media.genres,
      voteAverage: media.voteAverage,
      numberOfSeasons: media.numberOfSeasons,
      numberOfEpisodes: media.numberOfEpisodes,
    );
  }
}
