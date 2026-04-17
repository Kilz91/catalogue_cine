import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/conversation_card.dart';

/// Écran de la liste des conversations
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late final ChatBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ChatBloc>()..add(LoadConversationsEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
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
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              _bloc.add(LoadConversationsEvent());
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _ChatBackground(
        child: BlocBuilder<ChatBloc, ChatState>(
          bloc: _bloc,
          builder: (context, state) {
            final hasError = (state.errorMessage ?? '').trim().isNotEmpty;

            return Column(
              children: [
                _EntranceMotion(
                  delayMs: 40,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _ConversationsHero(
                      total: state.conversations.length,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: state.isLoadingConversations
                      ? const Padding(
                          key: ValueKey('conversations-syncing'),
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(
                            color: Color(0xFFAED3FF),
                            backgroundColor: Color(0xFF1B3B58),
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('conversations-not-syncing'),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: hasError
                      ? Padding(
                          key: ValueKey(
                            'conversations-error-${state.errorMessage}',
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          child: _ErrorBanner(
                            message: state.errorMessage!,
                            onRetry: () => _bloc.add(LoadConversationsEvent()),
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('conversations-no-error'),
                        ),
                ),
                Expanded(child: _buildBody(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(ChatState state) {
    if (state.isLoadingConversations && state.conversations.isEmpty) {
      return const _ConversationSkeletonList();
    }

    if (state.conversations.isEmpty) {
      return _ConversationEmptyState(
        onRefresh: () => _bloc.add(LoadConversationsEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(LoadConversationsEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: state.conversations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return _StaggerReveal(
            index: index,
            identity: 'conversation-${conversation.id}',
            child: ConversationCard(
              conversation: conversation,
              onTap: () {
                context.pushNamed(
                  'chatConversation',
                  pathParameters: {'conversationId': conversation.id},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatBackground extends StatelessWidget {
  final Widget child;

  const _ChatBackground({required this.child});

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
          top: -80,
          right: -60,
          child: _GlowCircle(
            diameter: 220,
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

class _ConversationsHero extends StatelessWidget {
  final int total;

  const _ConversationsHero({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17324A), Color(0xFF1F4E79)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tes conversations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Aucun fil actif pour le moment'
                      : '$total conversation(s) active(s)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.forum_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF571C23).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF8A80).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFFB4AB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reessayer')),
        ],
      ),
    );
  }
}

class _ConversationEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _ConversationEmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10253A).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 44,
                  color: Color(0xFFAED3FF),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune conversation',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Commence a discuter avec tes amis pour voir apparaitre tes fils ici.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7BF7),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversationSkeletonList extends StatelessWidget {
  const _ConversationSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _PulsingSkeleton(delayMs: index * 60);
      },
    );
  }
}

class _PulsingSkeleton extends StatefulWidget {
  final int delayMs;

  const _PulsingSkeleton({this.delayMs = 0});

  @override
  State<_PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<_PulsingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900 + widget.delayMs),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final alpha = 0.62 + (_animation.value * 0.18);

        return Container(
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFF17324C).withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
        );
      },
    );
  }
}

class _EntranceMotion extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _EntranceMotion({required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    const motionMs = 360;
    final totalMs = delayMs + motionMs;
    final start = delayMs == 0 ? 0.0 : delayMs / totalMs;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: animatedChild,
          ),
        );
      },
    );
  }
}

class _StaggerReveal extends StatelessWidget {
  final int index;
  final String identity;
  final Widget child;

  const _StaggerReveal({
    required this.index,
    required this.identity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = index.clamp(0, 10);
    final delayMs = clamped * 42;
    final totalMs = 260 + delayMs;
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
            offset: Offset(0, (1 - value) * 12),
            child: animatedChild,
          ),
        );
      },
    );
  }
}
