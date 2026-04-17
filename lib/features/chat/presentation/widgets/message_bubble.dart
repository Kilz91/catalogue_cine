import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Widget pour afficher une bulle de message
class MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
    final isMine = message.isMine(currentUserId);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isMine
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A7BF7), Color(0xFF3561D8)],
                  )
                : null,
            color: isMine ? null : const Color(0xFF17324C),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMine
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMine
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
            border: Border.all(
              color: isMine
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMine)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ),
                Text(
                  message.content,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isMine ? 1 : 0.94),
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(
                          alpha: isMine ? 0.82 : 0.68,
                        ),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
