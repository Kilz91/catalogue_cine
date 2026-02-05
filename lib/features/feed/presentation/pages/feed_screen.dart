import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(
        title: const Text('Fil d\'actualité'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Amis'),
            Tab(icon: Icon(Icons.lightbulb_outline), text: 'Recommandations'),
          ],
        ),
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        bloc: _bloc,
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildActivitiesTab(state),
              _buildRecommendationsTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivitiesTab(FeedState state) {
    if (state.isLoadingActivities && state.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune activité pour le moment',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _bloc.add(RefreshFeedEvent()),
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(RefreshFeedEvent());
      },
      child: ListView.builder(
        itemCount: state.activities.length,
        itemBuilder: (context, index) {
          final activity = state.activities[index];
          return ActivityCard(
            activity: activity,
            onTap: () {
              // TODO: Naviguer vers la page du média
              print('Naviguer vers ${activity.mediaId}');
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationsTab(FeedState state) {
    if (state.isLoadingRecommendations && state.recommendations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune recommandation pour le moment',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _bloc.add(LoadRecommendationsEvent()),
              child: const Text('Charger'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(LoadRecommendationsEvent());
      },
      child: ListView.builder(
        itemCount: state.recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = state.recommendations[index];
          return RecommendationCard(
            recommendation: recommendation,
            onTap: () {
              // TODO: Naviguer vers la page du média
              print('Naviguer vers ${recommendation.mediaId}');
            },
          );
        },
      ),
    );
  }
}
