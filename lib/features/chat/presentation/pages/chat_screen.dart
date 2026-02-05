import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/di/service_locator.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';

/// Écran de chat pour une conversation
class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatBloc _bloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ChatBloc>()
      ..add(LoadMessagesEvent(widget.conversationId))
      ..add(MarkMessagesAsReadEvent(widget.conversationId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _bloc.add(SendMessageEvent(
      conversationId: widget.conversationId,
      content: content,
    ));

    _messageController.clear();

    // Scroll vers le bas après l'envoi
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getOtherUserName() {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
    final conversation = _bloc.state.conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => _bloc.state.conversations.first,
    );
    return conversation.getOtherParticipantName(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatBloc, ChatState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state.conversations.isEmpty) {
              return const Text('Chat');
            }
            return Text(_getOtherUserName());
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state.isLoadingMessages && state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envoyez votre premier message',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll vers le bas quand de nouveaux messages arrivent
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Écrivez un message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ChatBloc, ChatState>(
              bloc: _bloc,
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isSending ? null : _sendMessage,
                  icon: state.isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
