import '../entities/media.dart';
import '../entities/user_media.dart';

/// Repository pour la feature Catalog
abstract class CatalogRepository {
  /// Recherche dans TMDb
  Future<List<Media>> searchMedia({
    required String query,
    required String type, // movie | tv | anime
  });

  /// Récupérer le catalogue utilisateur
  Future<List<UserMedia>> getUserCatalog({String? status});

  /// Ajouter un média au catalogue
  Future<UserMedia> addToCatalog({
    required Media media,
    required String status, // planned | watching | completed
  });

  /// Mettre à jour le statut d'un média
  Future<UserMedia> updateStatus({
    required String userMediaId,
    required String status,
  });

  /// Supprimer un média du catalogue
  Future<void> removeFromCatalog(String userMediaId);
}
