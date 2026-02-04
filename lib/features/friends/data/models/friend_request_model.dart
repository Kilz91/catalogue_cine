import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_request_entity.dart';

/// Model pour les demandes d'amis (Firestore)
class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String receiverId;
  final String? receiverName;
  final String? receiverEmail;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.receiverId,
    this.receiverName,
    this.receiverEmail,
    required this.status,
    required this.createdAt,
  });

  /// Conversion depuis Firestore
  factory FriendRequestModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'],
      receiverEmail: data['receiverEmail'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Conversion vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverEmail': receiverEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Conversion vers Entity
  FriendRequestEntity toEntity() {
    return FriendRequestEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderEmail: senderEmail,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverEmail: receiverEmail,
      status: status,
      createdAt: createdAt,
    );
  }
}
