import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

/// UseCase pour obtenir les messages d'une conversation
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<ChatMessageEntity>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}
