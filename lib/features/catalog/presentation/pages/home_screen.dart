import 'package:catalogue_cine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:catalogue_cine/features/auth/presentation/bloc/auth_event.dart';
import 'package:catalogue_cine/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';

/// Écran d'accueil principal
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue Ciné'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push(AppRoutes.feed);
            },
            tooltip: 'Fil d\'actualité',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.push(AppRoutes.chat);
            },
            tooltip: 'Messages',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              context.push(AppRoutes.friends);
            },
            tooltip: 'Amis',
          ),
          IconButton(
            icon: const Icon(Icons.movie_filter),
            onPressed: () {
              context.push(AppRoutes.catalog);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOutState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vous avez été déconnecté')),
            );
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) {
          if (state is AuthSuccessState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue ${state.user.displayName ?? state.user.email}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sections du catalogue (placeholder)
                  _buildSection(context, 'Mon Catalogue'),
                  _buildSection(context, 'Fil d\'actualité'),
                  _buildSection(context, 'Mes Amis'),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'À venir',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
