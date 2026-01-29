import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/user_media.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import 'media_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'movie';
  late CatalogBloc _catalogBloc;

  @override
  void initState() {
    super.initState();
    _catalogBloc = getIt<CatalogBloc>()..add(LoadCatalogEvent('planned'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _catalogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _catalogBloc,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Mon Catalogue'),
            centerTitle: true,
            bottom: TabBar(
              onTap: (index) {
                final status = _statusFromIndex(index);
                _catalogBloc.add(LoadCatalogEvent(status));
              },
              tabs: const [
                Tab(text: 'À voir'),
                Tab(text: 'En cours'),
                Tab(text: 'Terminé'),
              ],
            ),
          ),
          body: BlocConsumer<CatalogBloc, CatalogState>(
            listener: (context, state) {
              if (state.error != null && state.error!.isNotEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _catalogBloc.add(LoadCatalogEvent(state.statusFilter));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSearchBar(context, state),
                    const SizedBox(height: 16),
                    if (state.searchResults.isNotEmpty) ...[
                      _buildSectionTitle('Résultats TMDb'),
                      const SizedBox(height: 8),
                      ...state.searchResults.map(
                        (media) => _buildSearchResultTile(context, media),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _catalogBloc.add(ClearSearchEvent());
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Fermer les résultats'),
                      ),
                      const Divider(height: 32),
                    ],
                    _buildSectionTitle('Ma liste'),
                    const SizedBox(height: 8),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (state.catalog.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('Aucun média pour ce statut'),
                        ),
                      )
                    else
                      ...state.catalog.map(
                        (userMedia) => _buildUserMediaTile(context, userMedia),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, CatalogState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un film, série ou animé...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      _onSearch(context);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(value: 'movie', child: Text('Film')),
                    DropdownMenuItem(value: 'tv', child: Text('Série')),
                    DropdownMenuItem(value: 'anime', child: Text('Animé')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _searchType = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ? null : () => _onSearch(context),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher sur TMDb'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _catalogBloc.add(SearchMediaEvent(query: query, type: _searchType));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSearchResultTile(BuildContext context, Media media) {
    return Card(
      child: ListTile(
        leading: _buildPoster(media.posterPath),
        title: Text(media.title),
        subtitle: Text(_mediaSubtitle(media)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MediaDetailScreen(media: media)),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _showStatusPicker(context, media),
        ),
      ),
    );
  }

  Widget _buildUserMediaTile(BuildContext context, UserMedia userMedia) {
    return Card(
      child: ListTile(
        leading: _buildPoster(userMedia.media.posterPath),
        title: Text(userMedia.media.title),
        subtitle: Text(_statusLabel(userMedia.status)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MediaDetailScreen(media: userMedia.media),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              _catalogBloc.add(RemoveFromCatalogEvent(userMedia.id));
            } else {
              _catalogBloc.add(
                UpdateCatalogStatusEvent(
                  userMediaId: userMedia.id,
                  status: value,
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'planned', child: Text('À voir')),
            PopupMenuItem(value: 'watching', child: Text('En cours')),
            PopupMenuItem(value: 'completed', child: Text('Terminé')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'remove', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(String? path) {
    if (path == null || path.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.movie));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        '${ApiConstants.tmdbImageBaseUrl}$path',
        width: 48,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const CircleAvatar(child: Icon(Icons.movie));
        },
      ),
    );
  }

  String _mediaSubtitle(Media media) {
    final typeLabel = media.type == 'movie'
        ? 'Film'
        : media.type == 'tv'
        ? 'Série'
        : 'Animé';
    final year = media.releaseDate?.year;
    return year != null ? '$typeLabel • $year' : typeLabel;
  }

  String _statusFromIndex(int index) {
    switch (index) {
      case 1:
        return 'watching';
      case 2:
        return 'completed';
      default:
        return 'planned';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'watching':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      default:
        return 'À voir';
    }
  }

  Future<void> _showStatusPicker(BuildContext context, Media media) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('À voir'),
                onTap: () => Navigator.pop(context, 'planned'),
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('En cours'),
                onTap: () => Navigator.pop(context, 'watching'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Terminé'),
                onTap: () => Navigator.pop(context, 'completed'),
              ),
            ],
          ),
        );
      },
    );

    if (status != null) {
      _catalogBloc.add(AddToCatalogEvent(media: media, status: status));
    }
  }
}
