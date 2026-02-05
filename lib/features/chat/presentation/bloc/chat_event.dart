part of 'chat_bloc.dart';

abstract class ChatEvent {}

/// Charger les conversations
class LoadConversationsEvent extends ChatEvent {}

/// Charger les messages d'une conversation
class LoadMessagesEvent extends ChatEvent {
  final String conversationId;

  LoadMessagesEvent(this.conversationId);
}

/// Envoyer un message
class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String content;

  SendMessageEvent({
    required this.conversationId,
    required this.content,
  });
}

/// Créer ou obtenir une conversation
class CreateConversationEvent extends ChatEvent {
  final String friendId;

  CreateConversationEvent(this.friendId);
}

/// Marquer les messages comme lus
class MarkMessagesAsReadEvent extends ChatEvent {
  final String conversationId;

  MarkMessagesAsReadEvent(this.conversationId);
}
