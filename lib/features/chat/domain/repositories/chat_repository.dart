import '../entities/chat_conversation_entity.dart';
import '../entities/chat_message_entity.dart';

/// Repository abstrait pour le chat
abstract class ChatRepository {
  /// Obtenir les conversations de l'utilisateur (stream pour temps réel)
  Stream<List<ChatConversationEntity>> getConversations();

  /// Obtenir les messages d'une conversation (stream pour temps réel)
  Stream<List<ChatMessageEntity>> getMessages(String conversationId);

  /// Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Créer ou obtenir une conversation avec un ami
  Future<String> getOrCreateConversation(String friendId);

  /// Marquer les messages comme lus
  Future<void> markMessagesAsRead(String conversationId);
}
