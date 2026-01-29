import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_media.dart';
import 'media_model.dart';

/// Modèle UserMedia pour la couche data
class UserMediaModel {
  final String id;
  final String userId;
  final int mediaId;
  final String mediaType;
  final String status;
  final MediaModel media;
  final DateTime dateAdded;
  final DateTime? dateStarted;
  final DateTime? dateCompleted;

  UserMediaModel({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    required this.status,
    required this.media,
    required this.dateAdded,
    this.dateStarted,
    this.dateCompleted,
  });

  factory UserMediaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserMediaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      mediaId: data['mediaId'] ?? 0,
      mediaType: data['mediaType'] ?? 'movie',
      status: data['status'] ?? 'planned',
      media: MediaModel.fromJson(
        (data['media'] as Map<String, dynamic>?) ?? {},
      ),
      dateAdded: _parseDate(data['dateAdded']) ?? DateTime.now(),
      dateStarted: _parseDate(data['dateStarted']),
      dateCompleted: _parseDate(data['dateCompleted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mediaId': mediaId,
      'mediaType': mediaType,
      'status': status,
      'media': media.toJson(),
      'dateAdded': dateAdded.toIso8601String(),
      'dateStarted': dateStarted?.toIso8601String(),
      'dateCompleted': dateCompleted?.toIso8601String(),
    };
  }

  UserMedia toEntity() {
    return UserMedia(
      id: id,
      userId: userId,
      mediaId: mediaId,
      mediaType: mediaType,
      status: status,
      media: media.toEntity(),
      dateAdded: dateAdded,
      dateStarted: dateStarted,
      dateCompleted: dateCompleted,
    );
  }

  factory UserMediaModel.fromEntity(UserMedia media) {
    return UserMediaModel(
      id: media.id,
      userId: media.userId,
      mediaId: media.mediaId,
      mediaType: media.mediaType,
      status: media.status,
      media: MediaModel.fromEntity(media.media),
      dateAdded: media.dateAdded,
      dateStarted: media.dateStarted,
      dateCompleted: media.dateCompleted,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
