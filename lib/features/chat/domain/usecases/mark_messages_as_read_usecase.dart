import '../repositories/chat_repository.dart';

/// UseCase pour marquer les messages comme lus
class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<void> call(String conversationId) {
    return repository.markMessagesAsRead(conversationId);
  }
}
