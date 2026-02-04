/// Entity représentant une demande d'ami
class FriendRequestEntity {
  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String receiverId;
  final String? receiverName; // Nom du destinataire (pour les demandes envoyées)
  final String? receiverEmail; // Email du destinataire
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.receiverId,
    this.receiverName,
    this.receiverEmail,
    required this.status,
    required this.createdAt,
  });
}
