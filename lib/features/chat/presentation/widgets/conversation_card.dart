import 'package:flutter/material.dart';
import '../../domain/entities/chat_conversation_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:timeago/timeago.dart' as timeago;

/// Widget pour afficher une conversation
class ConversationCard extends StatelessWidget {
  final ChatConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
    final otherUserName = conversation.getOtherParticipantName(currentUserId);
    final otherUserImage = conversation.getOtherParticipantImage(currentUserId);
    final unreadCount = conversation.getUnreadCountForUser(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: otherUserImage.isNotEmpty
              ? NetworkImage(otherUserImage)
              : null,
          child: otherUserImage.isEmpty
              ? Text(otherUserName[0].toUpperCase())
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName,
                style: TextStyle(
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (conversation.lastMessageTime != null)
              Text(
                timeago.format(conversation.lastMessageTime!,
                    locale: 'fr_short'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage ?? 'Aucun message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight:
                      unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
