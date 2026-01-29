import 'media.dart';

/// Entité pour un média dans le catalogue d'un utilisateur
class UserMedia {
  final String id;
  final String userId;
  final int mediaId;
  final String mediaType; // 'movie', 'tv', 'anime'
  final String status; // 'planned', 'watching', 'completed'
  final Media media;
  final DateTime dateAdded;
  final DateTime? dateStarted;
  final DateTime? dateCompleted;

  UserMedia({
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

  UserMedia copyWith({
    String? id,
    String? userId,
    int? mediaId,
    String? mediaType,
    String? status,
    Media? media,
    DateTime? dateAdded,
    DateTime? dateStarted,
    DateTime? dateCompleted,
  }) {
    return UserMedia(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      media: media ?? this.media,
      dateAdded: dateAdded ?? this.dateAdded,
      dateStarted: dateStarted ?? this.dateStarted,
      dateCompleted: dateCompleted ?? this.dateCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMedia && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
