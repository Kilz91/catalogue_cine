import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/actor_bloc.dart';
import '../bloc/actor_event.dart';
import '../bloc/actor_state.dart';
import '../widgets/actor_info_card.dart';
import '../widgets/actor_credits_grid.dart';

/// Écran de détails d'un acteur
class ActorDetailsScreen extends StatelessWidget {
  final int actorId;

  const ActorDetailsScreen({
    super.key,
    required this.actorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActorBloc>()
        ..add(LoadActorCreditsEvent(actorId)),
      child: Scaffold(
        body: BlocBuilder<ActorBloc, ActorState>(
          builder: (context, state) {
            if (state is ActorLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ActorErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              );
            }

            if (state is ActorCreditsLoadedState) {
              final actor = state.actor;
              final credits = state.credits;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        actor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                      background: actor.profilePath != null
                          ? Image.network(
                              '${ApiConstants.tmdbImageBaseUrl}${actor.profilePath}',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ActorInfoCard(actor: actor),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Filmographie (${credits.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  ActorCreditsGrid(credits: credits),
                ],
              );
            }

            return const Center(child: Text('Aucune donnée'));
          },
        ),
      ),
    );
  }
}
