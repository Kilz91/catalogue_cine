import '../repositories/chat_repository.dart';

/// UseCase pour créer ou obtenir une conversation
class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  Future<String> call(String friendId) {
    return repository.getOrCreateConversation(friendId);
  }
}
