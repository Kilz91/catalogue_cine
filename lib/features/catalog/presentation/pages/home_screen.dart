import 'package:catalogue_cine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:catalogue_cine/features/auth/presentation/bloc/auth_event.dart';
import 'package:catalogue_cine/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Écran d'accueil principal
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Catalogue Cine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.pushNamed('feed');
            },
            tooltip: 'Fil d\'actualité',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.pushNamed('profile');
            },
            tooltip: 'Profil',
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'Options',
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == _MenuAction.logout) {
                context.read<AuthBloc>().add(LogoutEvent());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_MenuAction>(
                value: _MenuAction.logout,
                child: Text('Se deconnecter'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (_, state) => state is AuthLoggedOutState,
        listener: (context, state) {
          if (state is AuthLoggedOutState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vous avez été déconnecté')),
            );
            context.goNamed('login');
          }
        },
        builder: (context, state) {
          if (state is AuthSuccessState) {
            final rawName = (state.user.displayName ?? '').trim();
            final displayName = rawName.isEmpty ? 'Cinephile' : rawName;

            return _HomeBackground(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _HomeHero(
                        displayName: displayName,
                        email: state.user.email,
                        onCatalogTap: () => context.pushNamed('catalog'),
                        onChatTap: () => context.pushNamed('chat'),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Actions rapides',
                        subtitle: 'Tout ce qui compte, en un geste',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final action = _homeActions[index];
                        return _HomeActionCard(action: action);
                      }, childCount: _homeActions.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.08,
                          ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Parcours conseille',
                        subtitle: 'Un flow simple pour rester dans le rythme',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: const [
                          _FlowCard(
                            icon: Icons.explore_outlined,
                            title: 'Decouvrir de nouveaux titres',
                            subtitle:
                                'Parcourez les films et series, puis ajoutez-les a votre suivi.',
                            routeName: 'catalog',
                          ),
                          SizedBox(height: 12),
                          _FlowCard(
                            icon: Icons.campaign_outlined,
                            title: 'Voir l\'activite de vos amis',
                            subtitle:
                                'Consultez le feed pour suivre ce qui avance autour de vous.',
                            routeName: 'feed',
                          ),
                          SizedBox(height: 12),
                          _FlowCard(
                            icon: Icons.forum_outlined,
                            title: 'Discuter en direct',
                            subtitle:
                                'Ouvrez les conversations pour partager vos coups de coeur.',
                            routeName: 'chat',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const _HomeBackground(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  final Widget child;

  const _HomeBackground({required this.child});

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
          top: -90,
          right: -70,
          child: _GlowCircle(
            diameter: 240,
            color: Colors.lightBlueAccent.withValues(alpha: 0.19),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _GlowCircle(
            diameter: 270,
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

enum _MenuAction { logout }

class _HomeHero extends StatelessWidget {
  final String displayName;
  final String email;
  final VoidCallback onCatalogTap;
  final VoidCallback onChatTap;

  const _HomeHero({
    required this.displayName,
    required this.email,
    required this.onCatalogTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17324A), Color(0xFF1F4E79)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salut $displayName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCatalogTap,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Explorer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF17324A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChatTap,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Messages'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _HomeAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
  final Color startColor;
  final Color endColor;

  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
    required this.startColor,
    required this.endColor,
  });
}

const List<_HomeAction> _homeActions = [
  _HomeAction(
    title: 'Catalogue',
    subtitle: 'Trouver un titre',
    icon: Icons.movie_creation_outlined,
    routeName: 'catalog',
    startColor: Color(0xFF1A4F7A),
    endColor: Color(0xFF2E86C1),
  ),
  _HomeAction(
    title: 'Messages',
    subtitle: 'Continuer le chat',
    icon: Icons.forum_outlined,
    routeName: 'chat',
    startColor: Color(0xFF245C57),
    endColor: Color(0xFF2A9D8F),
  ),
  _HomeAction(
    title: 'Feed',
    subtitle: 'Voir les activites',
    icon: Icons.dynamic_feed_outlined,
    routeName: 'feed',
    startColor: Color(0xFF5B4B8A),
    endColor: Color(0xFF6D5BD0),
  ),
  _HomeAction(
    title: 'Amis',
    subtitle: 'Gerer le cercle',
    icon: Icons.groups_outlined,
    routeName: 'friends',
    startColor: Color(0xFF6A4A3C),
    endColor: Color(0xFFC67C4E),
  ),
];

class _HomeActionCard extends StatelessWidget {
  final _HomeAction action;

  const _HomeActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed(action.routeName),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [action.startColor, action.endColor],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(action.icon, color: Colors.white, size: 24),
                const Spacer(),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  const _FlowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed(routeName),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF10253A).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3A56),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFA9C8E3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
