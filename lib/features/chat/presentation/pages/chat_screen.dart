import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';

/// Écran de chat pour une conversation
class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatBloc _bloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onInputChanged);
    _bloc = getIt<ChatBloc>()
      ..add(LoadConversationsEvent())
      ..add(LoadMessagesEvent(widget.conversationId))
      ..add(MarkMessagesAsReadEvent(widget.conversationId));
  }

  @override
  void dispose() {
    _messageController.removeListener(_onInputChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onInputChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (_hasText == hasText) return;
    setState(() => _hasText = hasText);
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final target = _scrollController.position.maxScrollExtent;
    if (!animate) {
      _scrollController.jumpTo(target);
      return;
    }

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _bloc.state.isSending) return;

    if (!_isMessagingAllowedForCurrentConversation(_bloc.state)) {
      HapticFeedback.mediumImpact();
      _showFeedbackSnack(
        message:
            'Vous ne pouvez plus envoyer de messages a cette personne car vous n\'etes plus amis.',
        isError: true,
      );
      return;
    }

    HapticFeedback.lightImpact();

    _bloc.add(
      SendMessageEvent(conversationId: widget.conversationId, content: content),
    );

    _messageController.clear();

    // Scroll vers le bas après l'envoi
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  String _getOtherUserName(ChatState state) {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;

    for (final conversation in state.conversations) {
      if (conversation.id == widget.conversationId) {
        final name = conversation.getOtherParticipantName(currentUserId).trim();
        return name.isEmpty ? 'Chat' : name;
      }
    }

    return 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: BlocBuilder<ChatBloc, ChatState>(
          bloc: _bloc,
          builder: (context, state) {
            return Text(_getOtherUserName(state));
          },
        ),
      ),
      body: _ChatRoomBackground(
        child: BlocListener<ChatBloc, ChatState>(
          bloc: _bloc,
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              (current.errorMessage ?? '').trim().isNotEmpty,
          listener: (context, state) {
            final message = (state.errorMessage ?? '').trim();
            if (message.isEmpty) return;
            HapticFeedback.mediumImpact();
            _showFeedbackSnack(message: message, isError: true);
          },
          child: Column(
            children: [
              BlocBuilder<ChatBloc, ChatState>(
                bloc: _bloc,
                buildWhen: (previous, current) =>
                    previous.isSending != current.isSending,
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: state.isSending
                        ? Padding(
                            key: const ValueKey('chat-sending-banner'),
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF12304A,
                                ).withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFAED3FF),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Envoi du message...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('chat-idle-banner'),
                          ),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state.isLoadingMessages && state.messages.isEmpty) {
                      return const _MessageLoadingList();
                    }

                    if (state.messages.isEmpty) {
                      return const _MessageEmptyState();
                    }

                    if (state.messages.length != _lastMessageCount) {
                      final isFirstBatch = _lastMessageCount == 0;
                      _lastMessageCount = state.messages.length;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom(animate: !isFirstBatch);
                      });
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 14,
                      ),
                      itemCount: state.messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return _MessageReveal(
                          index: index,
                          identity: message.id,
                          child: MessageBubble(message: message),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _bloc,
      buildWhen: (previous, current) =>
          previous.isSending != current.isSending ||
          previous.conversations != current.conversations,
      builder: (context, state) {
        final isMessagingAllowed = _isMessagingAllowedForCurrentConversation(
          state,
        );
        final canSend = _hasText && !state.isSending && isMessagingAllowed;

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10253A).withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isMessagingAllowed
                      ? const SizedBox.shrink(key: ValueKey('chat-input-open'))
                      : Container(
                          key: const ValueKey('chat-input-locked'),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF571C23,
                            ).withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFFF8A80,
                              ).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFFFB4AB),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vous n\'etes plus amis. Conversation conservee en lecture seule.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: isMessagingAllowed,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: isMessagingAllowed
                              ? 'Ecris un message...'
                              : 'Envoi desactive',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF17324C),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      scale: canSend ? 1 : 0.95,
                      child: FilledButton(
                        onPressed: canSend ? _sendMessage : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7BF7),
                          disabledBackgroundColor: const Color(
                            0xFF4A7BF7,
                          ).withValues(alpha: 0.45),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: state.isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isMessagingAllowed
                                    ? Icons.send_rounded
                                    : Icons.lock_outline,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isMessagingAllowedForCurrentConversation(ChatState state) {
    for (final conversation in state.conversations) {
      if (conversation.id == widget.conversationId) {
        return conversation.isMessagingAllowed;
      }
    }
    return true;
  }

  void _showFeedbackSnack({required String message, required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isError
              ? const Color(0xFF9F2A24)
              : const Color(0xFF1D6B34),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

class _ChatRoomBackground extends StatelessWidget {
  final Widget child;

  const _ChatRoomBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1B263B),
                  Colors.blueGrey.shade700,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -85,
          right: -70,
          child: _GlowCircle(
            diameter: 230,
            color: Colors.lightBlueAccent.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _GlowCircle(
            diameter: 250,
            color: Colors.tealAccent.withValues(alpha: 0.16),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowCircle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10253A).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_outlined,
                size: 44,
                color: Color(0xFFAED3FF),
              ),
              const SizedBox(height: 10),
              Text(
                'Aucun message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Envoie le premier message pour lancer la discussion.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageLoadingList extends StatelessWidget {
  const _MessageLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final isMine = index.isOdd;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * (isMine ? 0.62 : 0.7),
            height: 56,
            decoration: BoxDecoration(
              color:
                  (isMine ? const Color(0xFF4A7BF7) : const Color(0xFF17324C))
                      .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _MessageReveal extends StatelessWidget {
  final int index;
  final String identity;
  final Widget child;

  const _MessageReveal({
    required this.index,
    required this.identity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = index.clamp(0, 14);
    final delayMs = clamped * 28;
    final totalMs = 220 + delayMs;
    final start = delayMs == 0 ? 0.0 : delayMs / totalMs;

    return TweenAnimationBuilder<double>(
      key: ValueKey(identity),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: animatedChild,
          ),
        );
      },
    );
  }
}
