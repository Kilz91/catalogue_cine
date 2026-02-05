/// Entité représentant un message de chat
class ChatMessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  /// Vérifier si le message appartient à l'utilisateur actuel
  bool isMine(String currentUserId) => senderId == currentUserId;
}
