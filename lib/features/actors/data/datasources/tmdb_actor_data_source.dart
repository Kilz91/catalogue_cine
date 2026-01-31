import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/actor_model.dart';
import '../../../catalog/data/models/media_model.dart';

/// DataSource pour les acteurs via TMDb
abstract class TmdbActorDataSource {
  Future<ActorModel> getActorDetails(int actorId);
  Future<List<MediaModel>> getActorCredits(int actorId);
  Future<List<ActorModel>> getMediaCast({
    required int mediaId,
    required String mediaType,
  });
}

class TmdbActorDataSourceImpl implements TmdbActorDataSource {
  final DioClient _dioClient;

  TmdbActorDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<ActorModel> getActorDetails(int actorId) async {
    final path =
        ApiConstants.personDetailsEndpoint.replaceAll('{id}', '$actorId');

    final response = await _dioClient.get(
      path,
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'language': ApiConstants.languageParam,
      },
    );

    return ActorModel.fromJson(response);
  }

  @override
  Future<List<MediaModel>> getActorCredits(int actorId) async {
    final path =
        ApiConstants.personCreditsEndpoint.replaceAll('{id}', '$actorId');

    final response = await _dioClient.get(
      path,
      queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'language': ApiConstants.languageParam,
      },
    );

    final cast = (response['cast'] as List?) ?? [];

    return cast.map((json) {
      final mediaType = json['media_type'] == 'movie' ? 'movie' : 'tv';
      return MediaModel.fromTmdbJson(json, mediaType);
    }).toList();
  }

  @override
  Future<List<ActorModel>> getMediaCast({
    required int mediaId,
    required String mediaType,
  }) async {
    final path = mediaType == 'movie'
        ? ApiConstants.movieCreditsEndpoint.replaceAll('{id}', '$mediaId')
        : ApiConstants.tvCreditsEndpoint.replaceAll('{id}', '$mediaId');

    try {
      final response = await _dioClient.get(
        path,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'language': ApiConstants.languageParam,
        },
      ).timeout(const Duration(seconds: 8));

      if (response == null || response is! Map) {
        return [];
      }

      final cast = (response['cast'] as List?) ?? [];

      if (cast.isEmpty) {
        return [];
      }

      return cast
          .map((json) => ActorModel.fromJson(json))
          .take(20)
          .toList();
    } catch (e) {
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }
}
