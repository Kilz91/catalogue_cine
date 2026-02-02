import '../entities/media.dart';
import '../entities/user_media.dart';
import '../repositories/catalog_repository.dart';

/// Rechercher dans TMDb
class SearchMediaUseCase {
  final CatalogRepository repository;
  SearchMediaUseCase(this.repository);

  Future<List<Media>> call({required String query, required String type}) {
    return repository.searchMedia(query: query, type: type);
  }
}

/// Récupérer les détails complets d'un média
class GetMediaDetailsUseCase {
  final CatalogRepository repository;
  GetMediaDetailsUseCase(this.repository);

  Future<Media> call({required int mediaId, required String type}) {
    return repository.getMediaDetails(mediaId: mediaId, type: type);
  }
}

/// Récupérer le catalogue utilisateur
class GetUserCatalogUseCase {
  final CatalogRepository repository;
  GetUserCatalogUseCase(this.repository);

  Future<List<UserMedia>> call({String? status}) {
    return repository.getUserCatalog(status: status);
  }
}

/// Ajouter un média
class AddToCatalogUseCase {
  final CatalogRepository repository;
  AddToCatalogUseCase(this.repository);

  Future<UserMedia> call({required Media media, required String status}) {
    return repository.addToCatalog(media: media, status: status);
  }
}

/// Mettre à jour le statut
class UpdateCatalogStatusUseCase {
  final CatalogRepository repository;
  UpdateCatalogStatusUseCase(this.repository);

  Future<UserMedia> call({
    required String userMediaId,
    required String status,
  }) {
    return repository.updateStatus(userMediaId: userMediaId, status: status);
  }
}

/// Supprimer un média
class RemoveFromCatalogUseCase {
  final CatalogRepository repository;
  RemoveFromCatalogUseCase(this.repository);

  Future<void> call(String userMediaId) {
    return repository.removeFromCatalog(userMediaId);
  }
}
