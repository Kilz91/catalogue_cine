import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/friendship_entity.dart';

/// Widget pour afficher un ami
class FriendCard extends StatefulWidget {
  final FriendshipEntity friendship;
  final VoidCallback onRemove;
  final VoidCallback onMessage;

  const FriendCard({
    super.key,
    required this.friendship,
    required this.onRemove,
    required this.onMessage,
  });

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final friendship = widget.friendship;
    final displayName = friendship.friendName.trim().isEmpty
        ? 'Utilisateur'
        : friendship.friendName.trim();
    final initial = displayName[0].toUpperCase();

    return AnimatedScale(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      scale: _isPressed ? 0.987 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onMessage();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                    alpha: _isPressed ? 0.16 : 0.22,
                  ),
                  blurRadius: _isPressed ? 10 : 18,
                  offset: Offset(0, _isPressed ? 4 : 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFAED3FF).withValues(alpha: 0.65),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFF1B3B58),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        friendship.friendEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ami depuis ${_formatDate(friendship.createdAt)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFFAED3FF),
                      ),
                      onPressed: widget.onMessage,
                      tooltip: 'Envoyer un message',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF8A80),
                      ),
                      onPressed: () =>
                          _showConfirmRemoval(context, displayName),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmRemoval(BuildContext context, String displayName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10253A),
          title: const Text(
            'Supprimer cet ami ?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer $displayName de vos amis ?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onRemove();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF8A80),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
