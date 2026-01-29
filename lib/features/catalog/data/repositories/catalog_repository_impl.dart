import '../../domain/entities/media.dart';
import '../../domain/entities/user_media.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../datasources/tmdb_remote_data_source.dart';
import '../models/media_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource catalogRemoteDataSource;
  final TmdbRemoteDataSource tmdbRemoteDataSource;

  CatalogRepositoryImpl({
    required this.catalogRemoteDataSource,
    required this.tmdbRemoteDataSource,
  });

  @override
  Future<List<Media>> searchMedia({
    required String query,
    required String type,
  }) async {
    final results = await tmdbRemoteDataSource.searchMedia(
      query: query,
      type: type,
    );
    return results.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<UserMedia>> getUserCatalog({String? status}) async {
    final models = await catalogRemoteDataSource.getUserCatalog(status: status);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<UserMedia> addToCatalog({
    required Media media,
    required String status,
  }) async {
    final model = await catalogRemoteDataSource.addToCatalog(
      media: MediaModel.fromEntity(media),
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<UserMedia> updateStatus({
    required String userMediaId,
    required String status,
  }) async {
    final model = await catalogRemoteDataSource.updateStatus(
      userMediaId: userMediaId,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<void> removeFromCatalog(String userMediaId) async {
    await catalogRemoteDataSource.removeFromCatalog(userMediaId);
  }
}
