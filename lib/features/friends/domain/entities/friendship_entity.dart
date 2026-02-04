/// Entity représentant une amitié établie
class FriendshipEntity {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendEmail;
  final DateTime createdAt;

  const FriendshipEntity({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
    required this.createdAt,
  });
}
