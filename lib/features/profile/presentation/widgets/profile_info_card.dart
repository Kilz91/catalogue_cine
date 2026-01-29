import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/user.dart';

/// Widget pour afficher les informations du profil
class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  Icons.info_outline,
                  'Biographie',
                  user.bio!,
                ),
                const Divider(height: 24),
              ],
              _buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
              if (user.createdAt != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  Icons.calendar_today,
                  'Membre depuis',
                  _formatDate(user.createdAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      // Fallback si la locale n'est pas disponible
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
