/// Clés pour les API externes
class ApiConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Clé API TMDb
  static const String tmdbApiKey = '2429a2f20c1592f674bfc8dd65baa7a3';

  // Endpoints TMDb
  static const String movieSearchEndpoint = '/search/movie';
  static const String tvSearchEndpoint = '/search/tv';
  static const String movieDetailsEndpoint = '/movie/{id}';
  static const String tvDetailsEndpoint = '/tv/{id}';
  static const String movieCreditsEndpoint = '/movie/{id}/credits';
  static const String tvCreditsEndpoint = '/tv/{id}/credits';
  static const String personDetailsEndpoint = '/person/{id}';
  static const String personCreditsEndpoint = '/person/{id}/combined_credits';

  // Paramètres
  static const String languageParam = 'fr-FR';
}
