import 'package:flutter/material.dart';
import '../../domain/entities/activity_entity.dart';

/// Widget pour afficher une activité d'ami
class ActivityCard extends StatelessWidget {
  final ActivityEntity activity;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: afficher l'URL du poster
    print('📸 Activity mediaPoster: "${activity.mediaPoster}"');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: activity.userImage.isNotEmpty
              ? NetworkImage(activity.userImage)
              : null,
          child: activity.userImage.isEmpty
              ? Text(activity.userName[0].toUpperCase())
              : null,
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: activity.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' ${activity.actionLabel}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        subtitle: Text(
          activity.mediaTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: activity.mediaPoster.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  activity.mediaPoster,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    print('❌ Erreur chargement image: ${activity.mediaPoster}');
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              )
            : Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.movie, color: Colors.grey),
              ),
        onTap: onTap,
      ),
    );
  }
}
