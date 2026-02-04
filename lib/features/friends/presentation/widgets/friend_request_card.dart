import 'package:flutter/material.dart';
import '../../domain/entities/friend_request_entity.dart';

/// Widget pour afficher une demande d'ami reçue
class ReceivedRequestCard extends StatelessWidget {
  final FriendRequestEntity request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ReceivedRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(request.senderName[0].toUpperCase()),
        ),
        title: Text(request.senderName),
        subtitle: Text(request.senderEmail),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onAccept,
              tooltip: 'Accepter',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onReject,
              tooltip: 'Refuser',
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une demande d'ami envoyée
class SentRequestCard extends StatelessWidget {
  final FriendRequestEntity request;
  final VoidCallback onCancel;

  const SentRequestCard({
    super.key,
    required this.request,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final receiverName = request.receiverName ?? 'Utilisateur';
    final receiverInitial = receiverName.isNotEmpty ? receiverName[0].toUpperCase() : '?';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(receiverInitial, style: const TextStyle(color: Colors.white)),
        ),
        title: Text('En attente'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(receiverName, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Envoyée le ${_formatDate(request.createdAt)}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: TextButton(
          onPressed: onCancel,
          child: const Text('Annuler'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
