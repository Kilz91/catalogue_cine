import 'package:equatable/equatable.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/user_media.dart';

class CatalogState extends Equatable {
  final bool isLoading;
  final List<UserMedia> catalog;
  final List<Media> searchResults;
  final String statusFilter;
  final String searchType;
  final String? error;

  const CatalogState({
    this.isLoading = false,
    this.catalog = const [],
    this.searchResults = const [],
    this.statusFilter = 'planned',
    this.searchType = 'movie',
    this.error,
  });

  CatalogState copyWith({
    bool? isLoading,
    List<UserMedia>? catalog,
    List<Media>? searchResults,
    String? statusFilter,
    String? searchType,
    String? error,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      catalog: catalog ?? this.catalog,
      searchResults: searchResults ?? this.searchResults,
      statusFilter: statusFilter ?? this.statusFilter,
      searchType: searchType ?? this.searchType,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    catalog,
    searchResults,
    statusFilter,
    searchType,
    error,
  ];
}
