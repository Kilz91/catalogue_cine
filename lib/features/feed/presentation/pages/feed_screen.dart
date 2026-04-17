import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/recommendation_card.dart';

/// Écran du fil d'actualité
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final FeedBloc _bloc;
  late final TabController _tabController;

  void _openMediaDetail({
    required String rawMediaId,
    required String rawMediaType,
  }) {
    final mediaId = int.tryParse(rawMediaId);
    if (mediaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d\'ouvrir ce media (identifiant invalide).',
          ),
        ),
      );
      return;
    }

    const validMediaTypes = {'movie', 'tv', 'anime'};
    final mediaType = validMediaTypes.contains(rawMediaType)
        ? rawMediaType
        : 'movie';

    context.pushNamed(
      'mediaDetailWithType',
      pathParameters: {'id': '$mediaId', 'type': mediaType},
    );
  }

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FeedBloc>()
      ..add(LoadFeedEvent())
      ..add(LoadRecommendationsEvent());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
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
        title: const Text('Fil d\'actualité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              _bloc.add(RefreshFeedEvent());
            },
            tooltip: 'Actualiser le feed',
          ),
        ],
      ),
      body: _FeedBackground(
        child: BlocBuilder<FeedBloc, FeedState>(
          bloc: _bloc,
          builder: (context, state) {
            final hasError = (state.errorMessage ?? '').trim().isNotEmpty;
            final isSyncing =
                state.isLoadingActivities || state.isLoadingRecommendations;

            return Column(
              children: [
                _EntranceMotion(
                  delayMs: 40,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildHeaderCard(context, state),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isSyncing
                      ? const Padding(
                          key: ValueKey('feed-syncing'),
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(
                            color: Color(0xFFAED3FF),
                            backgroundColor: Color(0xFF1B3B58),
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('feed-not-syncing'),
                        ),
                ),
                _EntranceMotion(
                  delayMs: 90,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _buildTabSwitcher(),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: hasError
                      ? Padding(
                          key: ValueKey('feed-error-${state.errorMessage}'),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _buildErrorBanner(state.errorMessage!),
                        )
                      : const SizedBox.shrink(key: ValueKey('feed-no-error')),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActivitiesTab(state),
                      _buildRecommendationsTab(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, FeedState state) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reste au coeur de l\'activite',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dynamic_feed_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Suis les actions de tes amis et decouvre des suggestions pertinentes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FeedMetricTile(
                  label: 'Activites',
                  value: '${state.activities.length}',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeedMetricTile(
                  label: 'Reco',
                  value: '${state.recommendations.length}',
                  icon: Icons.lightbulb_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF10253A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(10),
        indicator: BoxDecoration(
          color: const Color(0xFF4A7BF7),
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: (_) => HapticFeedback.selectionClick(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.74),
        tabs: const [
          Tab(icon: Icon(Icons.people_outline), text: 'Amis'),
          Tab(icon: Icon(Icons.lightbulb_outline), text: 'Recommandations'),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
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
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _bloc.add(RefreshFeedEvent()),
            child: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(FeedState state) {
    if (state.isLoadingActivities && state.activities.isEmpty) {
      return const _FeedLoadingList();
    }

    if (state.activities.isEmpty) {
      return _FeedEmptyState(
        icon: Icons.people_outline,
        title: 'Aucune activite pour le moment',
        subtitle:
            'Ajoute des amis et interagis avec des titres pour alimenter le feed.',
        buttonLabel: 'Actualiser',
        onPressed: () => _bloc.add(RefreshFeedEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(RefreshFeedEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        itemCount: state.activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final activity = state.activities[index];
          return _FeedStaggerReveal(
            index: index,
            identity: 'activity-${activity.id}',
            child: ActivityCard(
              activity: activity,
              onTap: () {
                _openMediaDetail(
                  rawMediaId: activity.mediaId,
                  rawMediaType: activity.mediaType,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationsTab(FeedState state) {
    if (state.isLoadingRecommendations && state.recommendations.isEmpty) {
      return const _FeedLoadingList();
    }

    if (state.recommendations.isEmpty) {
      return _FeedEmptyState(
        icon: Icons.lightbulb_outline,
        title: 'Aucune recommandation pour le moment',
        subtitle:
            'Lance un rafraichissement pour recuperer de nouvelles suggestions.',
        buttonLabel: 'Charger',
        onPressed: () => _bloc.add(LoadRecommendationsEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(LoadRecommendationsEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        itemCount: state.recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final recommendation = state.recommendations[index];
          return _FeedStaggerReveal(
            index: index,
            identity: 'recommendation-${recommendation.id}',
            child: RecommendationCard(
              recommendation: recommendation,
              onTap: () {
                _openMediaDetail(
                  rawMediaId: recommendation.mediaId,
                  rawMediaType: recommendation.mediaType,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EntranceMotion extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _EntranceMotion({required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    const motionMs = 380;
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

class _FeedStaggerReveal extends StatelessWidget {
  final int index;
  final String identity;
  final Widget child;

  const _FeedStaggerReveal({
    required this.index,
    required this.identity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = index.clamp(0, 10);
    final delayMs = clamped * 42;
    final totalMs = 280 + delayMs;
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
            offset: Offset(0, (1 - value) * 14),
            child: animatedChild,
          ),
        );
      },
    );
  }
}

class _FeedBackground extends StatelessWidget {
  final Widget child;

  const _FeedBackground({required this.child});

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

class _FeedMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _FeedMetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );

                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _FeedEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

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
                Icon(icon, size: 44, color: const Color(0xFFAED3FF)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.refresh),
                  label: Text(buttonLabel),
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

class _FeedLoadingList extends StatelessWidget {
  const _FeedLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _PulsingSkeletonTile(delayMs: index * 70);
      },
    );
  }
}

class _PulsingSkeletonTile extends StatefulWidget {
  final int delayMs;

  const _PulsingSkeletonTile({this.delayMs = 0});

  @override
  State<_PulsingSkeletonTile> createState() => _PulsingSkeletonTileState();
}

class _PulsingSkeletonTileState extends State<_PulsingSkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 980 + widget.delayMs),
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
          height: 110,
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
