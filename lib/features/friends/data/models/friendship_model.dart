import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friendship_entity.dart';

/// Model pour les amitiés établies (Firestore)
class FriendshipModel {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendEmail;
  final DateTime createdAt;

  FriendshipModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
    required this.createdAt,
  });

  /// Conversion depuis Firestore
  factory FriendshipModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendshipModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      friendId: data['friendId'] ?? '',
      friendName: data['friendName'] ?? '',
      friendEmail: data['friendEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendEmail': friendEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Conversion vers Entity
  FriendshipEntity toEntity() {
    return FriendshipEntity(
      id: id,
      userId: userId,
      friendId: friendId,
      friendName: friendName,
      friendEmail: friendEmail,
      createdAt: createdAt,
    );
  }
}
