import '../entities/chat_conversation_entity.dart';
import '../repositories/chat_repository.dart';

/// UseCase pour obtenir les conversations
class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Stream<List<ChatConversationEntity>> call() {
    return repository.getConversations();
  }
}
