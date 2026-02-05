import '../../domain/entities/chat_conversation_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implémentation du repository Chat
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatConversationEntity>> getConversations() {
    return remoteDataSource.getConversations().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String conversationId) {
    return remoteDataSource.getMessages(conversationId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) {
    return remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }

  @override
  Future<String> getOrCreateConversation(String friendId) {
    return remoteDataSource.getOrCreateConversation(friendId);
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) {
    return remoteDataSource.markMessagesAsRead(conversationId);
  }
}
