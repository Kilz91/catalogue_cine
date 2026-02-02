import '../entities/media.dart';
import '../repositories/catalog_repository.dart';

class GetMediaDetailsUseCase {
  final CatalogRepository repository;

  GetMediaDetailsUseCase(this.repository);

  Future<Media> call({
    required int mediaId,
    required String type,
  }) async {
    return await repository.getMediaDetails(
      mediaId: mediaId,
      type: type,
    );
  }
}
