import 'package:catalogue_cine/features/auth/domain/entities/user.dart';

/// Entité pour les messages de chat
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final User sender;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.sentAt,
    this.readAt,
    required this.sender,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? recipientId,
    String? content,
    DateTime? sentAt,
    DateTime? readAt,
    User? sender,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      sender: sender ?? this.sender,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
