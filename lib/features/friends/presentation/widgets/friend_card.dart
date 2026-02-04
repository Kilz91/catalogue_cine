import 'package:flutter/material.dart';
import '../../domain/entities/friendship_entity.dart';

/// Widget pour afficher un ami
class FriendCard extends StatelessWidget {
  final FriendshipEntity friendship;
  final VoidCallback onRemove;

  const FriendCard({
    super.key,
    required this.friendship,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            friendship.friendName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(friendship.friendName),
        subtitle: Text(friendship.friendEmail),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            // Confirmation avant suppression
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Supprimer cet ami ?'),
                content: Text(
                  'Voulez-vous vraiment supprimer ${friendship.friendName} de vos amis ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRemove();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            );
          },
          tooltip: 'Supprimer',
        ),
      ),
    );
  }
}
