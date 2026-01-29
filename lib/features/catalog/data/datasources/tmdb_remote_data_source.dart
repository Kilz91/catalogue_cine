import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/media_model.dart';

/// DataSource TMDb
abstract class TmdbRemoteDataSource {
  Future<List<MediaModel>> searchMedia({
    required String query,
    required String type, // movie | tv | anime
  });
}

class TmdbRemoteDataSourceImpl implements TmdbRemoteDataSource {
  final DioClient _dioClient;

  TmdbRemoteDataSourceImpl({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  @override
  Future<List<MediaModel>> searchMedia({
    required String query,
    required String type,
  }) async {
    final path = type == 'movie'
        ? ApiConstants.movieSearchEndpoint
        : ApiConstants.tvSearchEndpoint;

    final response = await _dioClient.get(
      path,
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'query': query,
        'language': ApiConstants.languageParam,
        'page': 1,
      },
    );

    final results = (response['results'] as List?) ?? [];

    List<Map<String, dynamic>> jsonResults = results
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    if (type == 'anime') {
      // Filtrer par genre Animation (id 16) pour simuler l'anime
      jsonResults = jsonResults.where((item) {
        final genreIds = (item['genre_ids'] as List?)?.cast<int>() ?? [];
        return genreIds.contains(16);
      }).toList();
    }

    return jsonResults
        .map((json) => MediaModel.fromTmdbJson(json, type))
        .toList();
  }
}
