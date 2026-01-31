import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../catalog/domain/entities/media.dart';

/// Grille affichant la filmographie d'un acteur
class ActorCreditsGrid extends StatelessWidget {
  final List<Media> credits;

  const ActorCreditsGrid({
    super.key,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    if (credits.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('Aucune filmographie disponible'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final media = credits[index];
            return _MediaCreditCard(media: media);
          },
          childCount: credits.length,
        ),
      ),
    );
  }
}

class _MediaCreditCard extends StatelessWidget {
  final Media media;

  const _MediaCreditCard({required this.media});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '${AppRoutes.mediaDetail}/${media.id}',
          extra: {'media': media},
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: media.posterPath != null
                  ? Image.network(
                      '${ApiConstants.tmdbImageBaseUrl}${media.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                media.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
