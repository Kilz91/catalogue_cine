/// Entité représentant une conversation de chat
class ChatConversationEntity {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames; // userId -> displayName
  final Map<String, String> participantImages; // userId -> photoURL
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount; // userId -> count

  const ChatConversationEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
  });

  /// Obtenir le nom de l'autre participant (conversation 1-1)
  String getOtherParticipantName(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? 'Utilisateur';
  }

  /// Obtenir l'image de l'autre participant (conversation 1-1)
  String getOtherParticipantImage(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantImages[otherId] ?? '';
  }

  /// Obtenir l'ID de l'autre participant (conversation 1-1)
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
  }

  /// Obtenir le nombre de messages non lus pour l'utilisateur actuel
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
