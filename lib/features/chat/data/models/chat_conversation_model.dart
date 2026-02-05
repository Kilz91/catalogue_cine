import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_conversation_entity.dart';

/// Modèle pour une conversation de chat
class ChatConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantImages;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;

  ChatConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
  });

  factory ChatConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatConversationModel(
      id: doc.id,
      participantIds: (data['participantIds'] as List?)?.cast<String>() ?? [],
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      participantImages: Map<String, String>.from(
        data['participantImages'] ?? {},
      ),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(
        (data['unreadCount'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value as int),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantImages': participantImages,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }

  ChatConversationEntity toEntity() {
    return ChatConversationEntity(
      id: id,
      participantIds: participantIds,
      participantNames: participantNames,
      participantImages: participantImages,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      unreadCount: unreadCount,
    );
  }
}
