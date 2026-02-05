import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity_entity.dart';

/// Model pour une activité (Firestore)
class ActivityModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String actionType;
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.actionType,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.timestamp,
  });

  /// Conversion depuis Firestore
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
      actionType: data['actionType'] ?? 'completed',
      mediaId: data['mediaId'] ?? '',
      mediaTitle: data['mediaTitle'] ?? '',
      mediaPoster: data['mediaPoster'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'actionType': actionType,
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaPoster': mediaPoster,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Conversion vers Entity
  ActivityEntity toEntity() {
    return ActivityEntity(
      id: id,
      userId: userId,
      userName: userName,
      userImage: userImage,
      actionType: actionType,
      mediaId: mediaId,
      mediaTitle: mediaTitle,
      mediaPoster: mediaPoster,
      timestamp: timestamp,
    );
  }
}
