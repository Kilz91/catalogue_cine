/// Entité représentant une recommandation
class RecommendationEntity {
  final String id;
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType; // 'movie', 'tv', 'anime'
  final String description;
  final List<String> genres;
  final double rating;
  final String reason; // Raison de la recommandation

  const RecommendationEntity({
    required this.id,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.mediaType,
    required this.description,
    required this.genres,
    required this.rating,
    required this.reason,
  });
}
