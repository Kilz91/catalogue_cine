import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/recommendation_entity.dart';

/// Widget pour afficher une recommandation
class RecommendationCard extends StatefulWidget {
  final RecommendationEntity recommendation;
  final VoidCallback onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.recommendation;
    final safeDescription = recommendation.description.trim();
    final safeReason = recommendation.reason.trim();

    return AnimatedScale(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      scale: _isPressed ? 0.987 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: const Color(
                0xFF10253A,
              ).withValues(alpha: _isPressed ? 0.9 : 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: _isPressed ? 0.2 : 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isPressed ? 0.18 : 0.24,
                  ),
                  blurRadius: _isPressed ? 10 : 18,
                  offset: Offset(0, _isPressed ? 4 : 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      _PosterHeader(posterUrl: recommendation.mediaPoster),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.74),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _InfoChip(
                          icon: Icons.movie_creation_outlined,
                          label: _mediaTypeLabel(recommendation.mediaType),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _InfoChip(
                          icon: Icons.star,
                          label:
                              '${recommendation.rating.toStringAsFixed(1)}/10',
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Text(
                          recommendation.mediaTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (safeDescription.isNotEmpty) ...[
                        Text(
                          safeDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            size: 16,
                            color: Color(0xFFAED3FF),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              safeReason.isEmpty
                                  ? 'Suggestion personnalisee'
                                  : safeReason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (recommendation.genres.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recommendation.genres
                              .take(3)
                              .map(
                                (genre) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF17324C),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    genre,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mediaTypeLabel(String mediaType) {
    switch (mediaType) {
      case 'tv':
        return 'Serie';
      case 'anime':
        return 'Anime';
      case 'movie':
      default:
        return 'Film';
    }
  }
}

class _PosterHeader extends StatelessWidget {
  final String posterUrl;

  const _PosterHeader({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    if (posterUrl.isEmpty) {
      return Container(
        height: 210,
        width: double.infinity,
        color: const Color(0xFF17324C),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFFAED3FF),
          size: 40,
        ),
      );
    }

    return Image.network(
      posterUrl,
      width: double.infinity,
      height: 210,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 210,
          width: double.infinity,
          color: const Color(0xFF17324C),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFAED3FF),
            size: 40,
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFAED3FF)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
