import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/media.dart';
import '../../domain/usecases/catalog_usecases.dart';
import '../../../actors/presentation/bloc/actor_bloc.dart';
import '../../../actors/presentation/bloc/actor_event.dart';
import '../../../actors/presentation/bloc/actor_state.dart';
import '../../../actors/presentation/widgets/media_cast_list.dart';
import '../../../progress/presentation/widgets/media_progress_card.dart';

class MediaDetailScreen extends StatefulWidget {
  final int mediaId;
  final Media? media;

  const MediaDetailScreen({
    super.key,
    required this.mediaId,
    this.media,
  });

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  Media? _loadedMedia;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si media est fourni, l'utiliser directement
    if (widget.media != null) {
      _loadedMedia = widget.media;
      // Charger les détails complets en arrière-plan pour avoir numberOfSeasons/numberOfEpisodes
      if (widget.media!.type == 'tv' || widget.media!.type == 'anime') {
        _loadMediaDetails();
      }
    } else {
      // Sinon, charger le média depuis l'API
      _loadMediaDetails();
    }
  }

  Future<void> _loadMediaDetails() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final useCase = getIt<GetMediaDetailsUseCase>();
      final detailedMedia = await useCase(
        mediaId: widget.mediaId,
        type: _loadedMedia?.type ?? 'movie', // Fallback si type inconnu
      );
      if (mounted) {
        setState(() {
          _loadedMedia = detailedMedia;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un écran de chargement si aucun média n'est disponible
    if (_loadedMedia == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final media = _loadedMedia!;

    return BlocProvider(
      create: (_) => getIt<ActorBloc>()
        ..add(LoadMediaCastEvent(
          mediaId: widget.mediaId,
          mediaType: media.type,
        )),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  media.title,
                  style: const TextStyle(
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
                background: _buildBackdrop(media),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetadata(context, media),
                    const SizedBox(height: 24),
                    if (media.overview != null &&
                        media.overview!.isNotEmpty) ...[
                      Text(
                        'Synopsis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        media.overview!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Widget suivi de progression
                    MediaProgressCard(
                      mediaId: widget.mediaId,
                      mediaType: media.type,
                      totalEpisodes: media.numberOfEpisodes ?? 1,
                      totalSeasons: media.numberOfSeasons ?? 1,
                      mediaTitle: media.title,
                      mediaPoster: media.posterPath != null
                          ? 'https://image.tmdb.org/t/p/w500${media.posterPath}'
                          : '',
                    ),
                    const SizedBox(height: 24),
                    if (media.genres.isNotEmpty) ...[
                      Text(
                        'Genres',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: media.genres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if ((media.type == 'tv' || media.type == 'anime') &&
                        (media.numberOfSeasons != null ||
                            media.numberOfEpisodes != null)) ...[
                      Text(
                        'Informations série',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (media.numberOfSeasons != null)
                        Text(
                          '${media.numberOfSeasons} saison(s)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (media.numberOfEpisodes != null)
                        Text(
                          '${media.numberOfEpisodes} épisode(s)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 24),
                    ],
                    // Cast section
                    BlocBuilder<ActorBloc, ActorState>(
                      builder: (context, state) {
                        if (state is MediaCastLoadedState) {
                          return MediaCastList(cast: state.cast);
                        }
                        if (state is ActorErrorState) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Impossible de charger le casting',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ActorLoadingState) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop(Media media) {
    final imagePath = media.backdropPath ?? media.posterPath;
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.movie, size: 64, color: Colors.white54),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          '${ApiConstants.tmdbImageBaseUrl}$imagePath',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.movie, size: 64, color: Colors.white54),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context, Media media) {
    return Row(
      children: [
        if (media.posterPath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '${ApiConstants.tmdbImageBaseUrl}${media.posterPath}',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTypeLabel(media),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (media.releaseDate != null)
                Text(
                  '${media.releaseDate!.year}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              if (media.voteAverage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      media.voteAverage!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(' / 10', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(Media media) {
    switch (media.type) {
      case 'movie':
        return 'Film';
      case 'tv':
        return 'Série TV';
      case 'anime':
        return 'Animé';
      default:
        return media.type.toUpperCase();
    }
  }
}
