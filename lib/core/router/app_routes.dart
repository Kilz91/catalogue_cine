/// Routes de l'application
abstract class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Home / Catalog Routes
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String mediaDetails = '/media/:id/:type';
  static const String addToLibrary = '/add-to-library/:id/:type';

  // Actors Routes
  static const String actorDetails = '/actor/:id';
  static const String actorCredits = '/actor/:id/credits';

  // Friends Routes
  static const String friends = '/friends';
  static const String friendProfile = '/friend/:id';
  static const String addFriend = '/add-friend/:id';

  // Feed Routes
  static const String feed = '/feed';

  // Chat Routes
  static const String chat = '/chat';
  static const String conversation = '/chat/:userId';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // Progress Routes
  static const String updateProgress = '/progress/:userMediaId';
}
