import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/friends_bloc.dart';
import '../bloc/friends_event.dart';
import '../bloc/friends_state.dart';
import '../widgets/friend_card.dart';
import '../widgets/friend_request_card.dart';

/// Écran principal de gestion des amis
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final FriendsBloc _bloc;
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FriendsBloc>()..add(LoadFriendsDataEvent());
    _tabController = TabController(length: 3, vsync: this);
    
    // Écouter les changements de texte pour la recherche
    _searchController.addListener(() {
      _bloc.add(SearchUsersEvent(_searchController.text));
    });
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes amis', icon: Icon(Icons.people)),
            Tab(text: 'Reçues', icon: Icon(Icons.mail)),
            Tab(text: 'Envoyées', icon: Icon(Icons.send)),
          ],
        ),
      ),
      body: BlocConsumer<FriendsBloc, FriendsState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsList(state),
              _buildReceivedRequestsList(state),
              _buildSentRequestsList(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriendDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildFriendsList(FriendsState state) {
    if (state.friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun ami pour le moment',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.builder(
        itemCount: state.friends.length,
        itemBuilder: (context, index) {
          final friendship = state.friends[index];
          return FriendCard(
            friendship: friendship,
            onRemove: () {
              _bloc.add(RemoveFriendEvent(friendship.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildReceivedRequestsList(FriendsState state) {
    if (state.receivedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune demande reçue',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.builder(
        itemCount: state.receivedRequests.length,
        itemBuilder: (context, index) {
          final request = state.receivedRequests[index];
          return ReceivedRequestCard(
            request: request,
            onAccept: () {
              _bloc.add(AcceptFriendRequestEvent(request.id));
            },
            onReject: () {
              _bloc.add(RejectFriendRequestEvent(request.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsList(FriendsState state) {
    if (state.sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune demande envoyée',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.builder(
        itemCount: state.sentRequests.length,
        itemBuilder: (context, index) {
          final request = state.sentRequests[index];
          return SentRequestCard(
            request: request,
            onCancel: () {
              _bloc.add(CancelFriendRequestEvent(request.id));
            },
          );
        },
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<FriendsBloc, FriendsState>(
        bloc: _bloc,
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Ajouter un ami'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // Liste des résultats
                  if (state.searchResults.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = state.searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              child: Text(user.displayName[0].toUpperCase()),
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(user.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () {
                                _bloc.add(SendFriendRequestEvent(user.userId));
                                _searchController.clear();
                                Navigator.pop(dialogContext);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  if (_searchController.text.isNotEmpty &&
                      state.searchResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aucun utilisateur trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }
}
