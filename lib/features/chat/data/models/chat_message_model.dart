import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';

/// Modèle pour un message de chat
class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImage: data['senderImage'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}
