/// Entité représentant une activité d'un ami
class ActivityEntity {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String actionType; // 'completed', 'started', 'recommended'
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final DateTime timestamp;

  const ActivityEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.actionType,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.timestamp,
  });

  String get actionLabel {
    switch (actionType) {
      case 'completed':
        return 'a terminé';
      case 'started':
        return 'a commencé';
      case 'planned':
        return 'veut voir';
      case 'recommended':
        return 'recommande';
      default:
        return 'a interagi avec';
    }
  }
}
