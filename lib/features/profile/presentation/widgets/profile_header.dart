import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';

/// Widget pour afficher l'en-tête du profil avec avatar
class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = (user.displayName ?? '').trim().isEmpty
        ? 'Utilisateur'
        : user.displayName!.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFAED3FF).withValues(alpha: 0.65),
              ),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFF1B3B58),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      _getInitials(displayName),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isVerified
                  ? const Color(0xFF4ADE80).withValues(alpha: 0.14)
                  : const Color(0xFFFFC857).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: user.isVerified
                    ? const Color(0xFF4ADE80).withValues(alpha: 0.6)
                    : const Color(0xFFFFC857).withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isVerified ? Icons.verified : Icons.pending_outlined,
                  size: 16,
                  color: user.isVerified
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFFC857),
                ),
                const SizedBox(width: 6),
                Text(
                  user.isVerified
                      ? 'Compte verifie'
                      : 'Verification en attente',
                  style: TextStyle(
                    color: user.isVerified
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFFC857),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
