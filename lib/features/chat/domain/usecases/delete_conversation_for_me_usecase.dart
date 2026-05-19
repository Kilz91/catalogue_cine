import '../repositories/chat_repository.dart';

/// UseCase pour supprimer (masquer) une conversation seulement pour l'utilisateur actuel
class DeleteConversationForMeUseCase {
  final ChatRepository repository;

  DeleteConversationForMeUseCase(this.repository);

  Future<void> call(String conversationId) {
    return repository.deleteConversationForMe(conversationId);
  }
}
