import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/activity_entity.dart';

/// Widget pour afficher une activité d'ami
class ActivityCard extends StatefulWidget {
  final ActivityEntity activity;
  final VoidCallback onTap;

  const ActivityCard({super.key, required this.activity, required this.onTap});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final safeUserName = activity.userName.trim().isEmpty
        ? 'Ami'
        : activity.userName.trim();

    return AnimatedScale(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      scale: _isPressed ? 0.986 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.circular(18),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityAvatar(
                  userImage: activity.userImage,
                  userName: safeUserName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: safeUserName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${activity.actionLabel}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TimeChip(
                            value: _formatRelativeTime(activity.timestamp),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.mediaTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17324C),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _actionIcon(activity.actionType),
                              size: 14,
                              color: const Color(0xFFAED3FF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _mediaTypeLabel(activity.mediaType),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PosterPreview(posterUrl: activity.mediaPoster),
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
        return 'SERIE';
      case 'anime':
        return 'ANIME';
      case 'movie':
      default:
        return 'FILM';
    }
  }

  IconData _actionIcon(String actionType) {
    switch (actionType) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'planned':
        return Icons.bookmark_outline;
      case 'recommended':
        return Icons.recommend_outlined;
      case 'started':
      default:
        return Icons.play_circle_outline;
    }
  }

  String _formatRelativeTime(DateTime timestamp) {
    final delta = DateTime.now().difference(timestamp);
    if (delta.inMinutes < 1) return 'A l\'instant';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m';
    if (delta.inHours < 24) return '${delta.inHours}h';
    if (delta.inDays < 7) return '${delta.inDays}j';
    if (delta.inDays < 30) return '${(delta.inDays / 7).floor()}sem';
    return '${(delta.inDays / 30).floor()}mo';
  }
}

class _ActivityAvatar extends StatelessWidget {
  final String userImage;
  final String userName;

  const _ActivityAvatar({required this.userImage, required this.userName});

  @override
  Widget build(BuildContext context) {
    final initial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFAED3FF).withValues(alpha: 0.65),
        ),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF1B3B58),
        backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
        child: userImage.isEmpty
            ? Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  final String posterUrl;

  const _PosterPreview({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    if (posterUrl.isEmpty) {
      return Container(
        width: 52,
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFF17324C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: const Icon(
          Icons.movie_outlined,
          color: Color(0xFFAED3FF),
          size: 20,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        posterUrl,
        width: 52,
        height: 76,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 52,
            height: 76,
            color: const Color(0xFF17324C),
            child: const Icon(Icons.image_not_supported_outlined, size: 18),
          );
        },
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String value;

  const _TimeChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
