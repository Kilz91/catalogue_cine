import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recommendation_entity.dart';

/// Model pour une recommandation (Firestore)
class RecommendationModel {
  final String id;
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType;
  final String description;
  final List<String> genres;
  final double rating;
  final String reason;

  RecommendationModel({
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

  /// Conversion depuis Firestore
  factory RecommendationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecommendationModel(
      id: doc.id,
      mediaId: data['mediaId'] ?? '',
      mediaTitle: data['mediaTitle'] ?? '',
      mediaPoster: data['mediaPoster'] ?? '',
      mediaType: data['mediaType'] ?? 'movie',
      description: data['description'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reason: data['reason'] ?? '',
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaPoster': mediaPoster,
      'mediaType': mediaType,
      'description': description,
      'genres': genres,
      'rating': rating,
      'reason': reason,
    };
  }

  /// Conversion vers Entity
  RecommendationEntity toEntity() {
    return RecommendationEntity(
      id: id,
      mediaId: mediaId,
      mediaTitle: mediaTitle,
      mediaPoster: mediaPoster,
      mediaType: mediaType,
      description: description,
      genres: genres,
      rating: rating,
      reason: reason,
    );
  }
}
