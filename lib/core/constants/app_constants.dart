/// Constantes d'application
class AppConstants {
  // Constantes réseau
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Constantes métier
  static const int pageSize = 20;
  static const int maxFriendRequests = 100;
  static const int maxChatMessageLength = 5000;

  // Types de médias
  static const String movieType = 'movie';
  static const String tvType = 'tv';
  static const String animeType = 'anime';

  // Statuts de progression
  static const String statusPlanned = 'planned';
  static const String statusWatching = 'watching';
  static const String statusCompleted = 'completed';
}
