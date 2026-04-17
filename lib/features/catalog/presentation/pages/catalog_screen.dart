import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/user_media.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
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
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1B2A),
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            title: const Text('Mon Catalogue'),
            bottom: TabBar(
              indicatorColor: const Color(0xFFAED3FF),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
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
            listenWhen: (previous, current) =>
                previous.error != current.error &&
                current.error != null &&
                current.error!.isNotEmpty,
            listener: (context, state) {
              if (state.error != null && state.error!.isNotEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
            builder: (context, state) {
              return _CatalogBackground(
                child: RefreshIndicator(
                  color: Colors.white,
                  onRefresh: () async {
                    _catalogBloc.add(LoadCatalogEvent(state.statusFilter));
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSearchPanel(context, state),
                      const SizedBox(height: 20),
                      if (state.searchResults.isNotEmpty) ...[
                        _buildSectionHeader(
                          title: 'Resultats TMDb',
                          subtitle:
                              '${state.searchResults.length} proposition(s) trouvee(s)',
                        ),
                        const SizedBox(height: 10),
                        ...state.searchResults.map(
                          (media) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildSearchResultTile(context, media),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              _catalogBloc.add(ClearSearchEvent());
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Fermer les resultats'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFAED3FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      _buildSectionHeader(
                        title: 'Ma liste',
                        subtitle: _statusLabel(state.statusFilter),
                      ),
                      const SizedBox(height: 10),
                      if (state.isLoading && state.catalog.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (state.catalog.isEmpty)
                        _buildEmptyState()
                      else
                        ...state.catalog.map(
                          (userMedia) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildUserMediaTile(context, userMedia),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPanel(BuildContext context, CatalogState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Color(0xFFF4F8FC)),
            decoration: InputDecoration(
              hintText: 'Rechercher un film, une serie, un anime...',
              hintStyle: const TextStyle(color: Color(0xFF9BB2C7)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF9BB2C7),
              ),
              filled: true,
              fillColor: const Color(0xFF17324C).withValues(alpha: 0.85),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2E4B67)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF6EA8FF),
                  width: 1.7,
                ),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _onSearch(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(value: 'movie', label: 'Film'),
              _buildTypeChip(value: 'tv', label: 'Serie'),
              _buildTypeChip(value: 'anime', label: 'Anime'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isLoading ? null : _onSearch,
              icon: const Icon(Icons.travel_explore_rounded),
              label: const Text('Rechercher sur TMDb'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7BF7),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({required String value, required String label}) {
    final isSelected = _searchType == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _searchType = value;
        });
      },
      backgroundColor: const Color(0xFF1B3B58),
      selectedColor: const Color(0xFFAED3FF),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF6EA8FF)
            : Colors.white.withValues(alpha: 0.2),
      ),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0D1B2A) : Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _catalogBloc.add(SearchMediaEvent(query: query, type: _searchType));
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 34,
            color: Colors.white.withValues(alpha: 0.82),
          ),
          const SizedBox(height: 10),
          Text(
            'Aucun media pour ce statut',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez un titre depuis la recherche.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(BuildContext context, Media media) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildPoster(media.posterPath),
        title: Text(
          media.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _mediaSubtitle(media),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        onTap: () {
          context.pushNamed(
            'mediaDetail',
            pathParameters: {'id': '${media.id}'},
            extra: {'media': media},
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFAED3FF)),
          onPressed: () => _showStatusPicker(context, media),
        ),
      ),
    );
  }

  Widget _buildUserMediaTile(BuildContext context, UserMedia userMedia) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildPoster(userMedia.media.posterPath),
        title: Text(
          userMedia.media.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: _buildStatusBadge(userMedia.status),
        onTap: () {
          context.pushNamed(
            'mediaDetail',
            pathParameters: {'id': '${userMedia.media.id}'},
            extra: {'media': userMedia.media},
          );
        },
        trailing: PopupMenuButton<String>(
          color: const Color(0xFF17324C),
          iconColor: const Color(0xFFAED3FF),
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
            PopupMenuItem(value: 'planned', child: Text('A voir')),
            PopupMenuItem(value: 'watching', child: Text('En cours')),
            PopupMenuItem(value: 'completed', child: Text('Termine')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'remove', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (label, color) = switch (status) {
      'watching' => ('En cours', const Color(0xFFFFC857)),
      'completed' => ('Termine', const Color(0xFF4ADE80)),
      _ => ('A voir', const Color(0xFF7DD3FC)),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        width: 48,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF1B3B58),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.movie_outlined, color: Color(0xFFAED3FF)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        '${ApiConstants.tmdbImageBaseUrl}$path',
        width: 48,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3B58),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.movie_outlined, color: Color(0xFFAED3FF)),
          );
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

  int _indexFromStatus(String status) {
    switch (status) {
      case 'watching':
        return 1;
      case 'completed':
        return 2;
      default:
        return 0;
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
    final focusScope = FocusScope.of(context);
    final tabController = DefaultTabController.maybeOf(context);

    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF10253A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF7DD3FC),
                ),
                title: const Text(
                  'A voir',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'planned'),
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Color(0xFFFFC857)),
                title: const Text(
                  'En cours',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'watching'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4ADE80),
                ),
                title: const Text(
                  'Termine',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'completed'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (status != null) {
      _searchController.clear();
      focusScope.unfocus();
      _catalogBloc.add(ClearSearchEvent());

      tabController?.animateTo(_indexFromStatus(status));

      _catalogBloc.add(AddToCatalogEvent(media: media, status: status));
    }
  }
}

class _CatalogBackground extends StatelessWidget {
  final Widget child;

  const _CatalogBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1B263B),
                  Colors.blueGrey.shade700,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _GlowCircle(
            diameter: 220,
            color: Colors.lightBlueAccent.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _GlowCircle(
            diameter: 250,
            color: Colors.tealAccent.withValues(alpha: 0.16),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowCircle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
