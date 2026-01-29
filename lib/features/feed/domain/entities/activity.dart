import 'package:catalogue_cine/features/catalog/domain/entities/media.dart';

import '../../../auth/domain/entities/user.dart';

/// Entité pour les activités dans le feed
class Activity {
  final String id;
  final String userId;
  final User user;
  final String actionType; // 'completed', 'rating', 'recommendation', 'started'
  final int? mediaId;
  final Media? media;
  final String? comment;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.user,
    required this.actionType,
    this.mediaId,
    this.media,
    this.comment,
    required this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? userId,
    User? user,
    String? actionType,
    int? mediaId,
    Media? media,
    String? comment,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      actionType: actionType ?? this.actionType,
      mediaId: mediaId ?? this.mediaId,
      media: media ?? this.media,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
