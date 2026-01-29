import '../../domain/entities/media.dart';

abstract class CatalogEvent {}

class LoadCatalogEvent extends CatalogEvent {
  final String status; // planned | watching | completed
  LoadCatalogEvent(this.status);
}

class SearchMediaEvent extends CatalogEvent {
  final String query;
  final String type; // movie | tv | anime
  SearchMediaEvent({required this.query, required this.type});
}

class ClearSearchEvent extends CatalogEvent {}

class AddToCatalogEvent extends CatalogEvent {
  final Media media;
  final String status;
  AddToCatalogEvent({required this.media, required this.status});
}

class UpdateCatalogStatusEvent extends CatalogEvent {
  final String userMediaId;
  final String status;
  UpdateCatalogStatusEvent({required this.userMediaId, required this.status});
}

class RemoveFromCatalogEvent extends CatalogEvent {
  final String userMediaId;
  RemoveFromCatalogEvent(this.userMediaId);
}
