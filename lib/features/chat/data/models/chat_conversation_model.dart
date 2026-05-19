import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_conversation_entity.dart';

/// Modèle pour une conversation de chat
class ChatConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantImages;
  final bool isMessagingAllowed;
  final List<String> deletedForUserIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;

  ChatConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    this.isMessagingAllowed = true,
    this.deletedForUserIds = const [],
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
      isMessagingAllowed: data['isMessagingAllowed'] != false,
      deletedForUserIds: (data['deletedFor'] as List?)?.cast<String>() ?? [],
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
      'isMessagingAllowed': isMessagingAllowed,
      'deletedFor': deletedForUserIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
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
      isMessagingAllowed: isMessagingAllowed,
      deletedForUserIds: deletedForUserIds,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      unreadCount: unreadCount,
    );
  }
}
