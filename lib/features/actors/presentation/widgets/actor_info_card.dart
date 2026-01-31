import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/actor.dart';

/// Card affichant les informations d'un acteur
class ActorInfoCard extends StatelessWidget {
  final Actor actor;

  const ActorInfoCard({
    super.key,
    required this.actor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (actor.biography != null && actor.biography!.isNotEmpty) ...[
              Text(
                'Biographie',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                actor.biography!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            if (actor.birthDate != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.cake,
                label: 'Date de naissance',
                value: DateFormat('dd MMMM yyyy', 'fr_FR').format(actor.birthDate!),
              ),
              const SizedBox(height: 8),
            ],
            if (actor.birthPlace != null && actor.birthPlace!.isNotEmpty) ...[
              _buildInfoRow(
                context,
                icon: Icons.location_on,
                label: 'Lieu de naissance',
                value: actor.birthPlace!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
