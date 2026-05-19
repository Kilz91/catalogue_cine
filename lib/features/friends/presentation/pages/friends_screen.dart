import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../chat/domain/usecases/get_or_create_conversation_usecase.dart';
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
  bool _isCreatingConversation = false;
  String? _pendingActionKey;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FriendsBloc>()..add(LoadFriendsDataEvent());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_currentTabIndex == _tabController.index) return;
      setState(() => _currentTabIndex = _tabController.index);
    });

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
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text('Amis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              _bloc.add(LoadFriendsDataEvent());
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _FriendsBackground(
        child: BlocConsumer<FriendsBloc, FriendsState>(
          bloc: _bloc,
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.successMessage != current.successMessage ||
              previous.isLoading != current.isLoading,
          listener: (context, state) {
            if (!state.isLoading && _pendingActionKey != null) {
              _clearPendingAction();
            }

            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              HapticFeedback.mediumImpact();
              _showFeedbackSnack(message: state.errorMessage!, isError: true);
            }

            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              HapticFeedback.selectionClick();
              _showFeedbackSnack(
                message: state.successMessage!,
                isError: false,
              );
            }
          },
          builder: (context, state) {
            final isInitialLoading =
                state.isLoading &&
                state.friends.isEmpty &&
                state.receivedRequests.isEmpty &&
                state.sentRequests.isEmpty;

            if (isInitialLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Column(
              children: [
                _EntranceMotion(
                  delayMs: 40,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _FriendsHero(state: state),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: state.isLoading
                      ? const Padding(
                          key: ValueKey('friends-syncing'),
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(
                            color: Color(0xFFAED3FF),
                            backgroundColor: Color(0xFF1B3B58),
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('friends-not-syncing'),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _pendingActionKey == null
                      ? const SizedBox.shrink(
                          key: ValueKey('no-pending-action'),
                        )
                      : Padding(
                          key: ValueKey(_pendingActionKey),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                                    _pendingActionLabel(_pendingActionKey),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                _EntranceMotion(
                  delayMs: 90,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _buildTabSwitcher(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsList(state),
                      _buildReceivedRequestsList(state),
                      _buildSentRequestsList(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pendingActionKey == null ? _showAddFriendDialog : null,
        icon: const Icon(Icons.person_add),
        label: Text(_currentTabIndex == 0 ? 'Ajouter' : 'Nouvel ami'),
        backgroundColor: const Color(0xFF4A7BF7),
        foregroundColor: Colors.white,
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
          Tab(text: 'Mes amis', icon: Icon(Icons.people_outline)),
          Tab(text: 'Recues', icon: Icon(Icons.mail_outline)),
          Tab(text: 'Envoyees', icon: Icon(Icons.send_outlined)),
        ],
      ),
    );
  }

  Widget _buildFriendsList(FriendsState state) {
    if (state.friends.isEmpty) {
      return _FriendsEmptyState(
        icon: Icons.people_outline,
        title: 'Aucun ami pour le moment',
        subtitle: 'Ajoute des amis pour lancer des conversations et partager.',
        buttonLabel: 'Actualiser',
        onPressed: () => _bloc.add(LoadFriendsDataEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.friends.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final friendship = state.friends[index];
          return _StaggerReveal(
            index: index,
            identity: 'friend-${friendship.id}',
            child: FriendCard(
              friendship: friendship,
              isProcessing:
                  _isActionPending('remove-${friendship.id}') ||
                  _isActionPending('message-${friendship.friendId}'),
              onRemove: () {
                _dispatchAction(
                  actionKey: 'remove-${friendship.id}',
                  event: RemoveFriendEvent(friendship.id),
                );
              },
              onMessage: () async {
                _startConversation(friendship.friendId, friendship.friendName);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceivedRequestsList(FriendsState state) {
    if (state.receivedRequests.isEmpty) {
      return _FriendsEmptyState(
        icon: Icons.mail_outline,
        title: 'Aucune demande recue',
        subtitle: 'Les nouvelles demandes d\'amis apparaitront ici.',
        buttonLabel: 'Actualiser',
        onPressed: () => _bloc.add(LoadFriendsDataEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.receivedRequests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final request = state.receivedRequests[index];
          return _StaggerReveal(
            index: index,
            identity: 'received-${request.id}',
            child: ReceivedRequestCard(
              request: request,
              isProcessing:
                  _isActionPending('accept-${request.id}') ||
                  _isActionPending('reject-${request.id}'),
              onAccept: () {
                _dispatchAction(
                  actionKey: 'accept-${request.id}',
                  event: AcceptFriendRequestEvent(request.id),
                );
              },
              onReject: () {
                _dispatchAction(
                  actionKey: 'reject-${request.id}',
                  event: RejectFriendRequestEvent(request.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsList(FriendsState state) {
    if (state.sentRequests.isEmpty) {
      return _FriendsEmptyState(
        icon: Icons.send_outlined,
        title: 'Aucune demande envoyee',
        subtitle: 'Envoie une invitation pour agrandir ton cercle.',
        buttonLabel: 'Actualiser',
        onPressed: () => _bloc.add(LoadFriendsDataEvent()),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: () async {
        _bloc.add(LoadFriendsDataEvent());
      },
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.sentRequests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final request = state.sentRequests[index];
          return _StaggerReveal(
            index: index,
            identity: 'sent-${request.id}',
            child: SentRequestCard(
              request: request,
              isProcessing: _isActionPending('cancel-${request.id}'),
              onCancel: () {
                _dispatchAction(
                  actionKey: 'cancel-${request.id}',
                  event: CancelFriendRequestEvent(request.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddFriendDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10253A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => BlocBuilder<FriendsBloc, FriendsState>(
        bloc: _bloc,
        builder: (context, state) {
          final friendIds = state.friends
              .map((friendship) => friendship.friendId)
              .toSet();
          final sentRequestUserIds = state.sentRequests
              .where((request) => request.status == 'pending')
              .map((request) => request.receiverId)
              .toSet();
          final receivedRequestUserIds = state.receivedRequests
              .where((request) => request.status == 'pending')
              .map((request) => request.senderId)
              .toSet();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Ajouter un ami',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Fermer',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFAED3FF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF17324C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // Liste des résultats
                  if (state.searchResults.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 14,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        itemBuilder: (context, index) {
                          final user = state.searchResults[index];
                          final initial = user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?';
                          final userId = user.userId;
                          final isAlreadyFriend = friendIds.contains(userId);
                          final hasPendingSentRequest = sentRequestUserIds
                              .contains(userId);
                          final hasPendingReceivedRequest =
                              receivedRequestUserIds.contains(userId);
                          final isSending = _isActionPending('send-$userId');

                          final canSendRequest =
                              !isAlreadyFriend &&
                              !hasPendingSentRequest &&
                              !hasPendingReceivedRequest &&
                              _pendingActionKey == null;

                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1B3B58),
                              child: Text(
                                initial,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: isSending
                                  ? const SizedBox(
                                      key: ValueKey('search-sending'),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFAED3FF),
                                      ),
                                    )
                                  : isAlreadyFriend
                                  ? const _SearchStatusPill(
                                      key: ValueKey('search-status-friend'),
                                      label: 'Deja ami',
                                      icon: Icons.check_circle_outline,
                                      color: Color(0xFF5CCF8A),
                                    )
                                  : hasPendingSentRequest
                                  ? const _SearchStatusPill(
                                      key: ValueKey('search-status-sent'),
                                      label: 'Envoyee',
                                      icon: Icons.schedule_outlined,
                                      color: Color(0xFFFFC857),
                                    )
                                  : hasPendingReceivedRequest
                                  ? _SearchStatusPill(
                                      key: const ValueKey(
                                        'search-status-received',
                                      ),
                                      label: 'Recue',
                                      icon: Icons.mail_outline,
                                      color: const Color(0xFFAED3FF),
                                      onTap: () => _openReceivedTabFromSearch(
                                        sheetContext,
                                      ),
                                    )
                                  : IconButton(
                                      key: const ValueKey('search-status-add'),
                                      icon: const Icon(
                                        Icons.person_add,
                                        color: Color(0xFFAED3FF),
                                      ),
                                      onPressed: canSendRequest
                                          ? () {
                                              _dispatchAction(
                                                actionKey: 'send-$userId',
                                                event: SendFriendRequestEvent(
                                                  userId,
                                                ),
                                              );
                                              _searchController.clear();
                                              Navigator.pop(sheetContext);
                                            }
                                          : null,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_searchController.text.isNotEmpty &&
                      state.searchResults.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aucun utilisateur trouvé',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      _searchController.clear();
    });
  }

  void _openReceivedTabFromSearch(BuildContext sheetContext) {
    HapticFeedback.selectionClick();
    _searchController.clear();

    if (Navigator.canPop(sheetContext)) {
      Navigator.pop(sheetContext);
    }

    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _tabController.animateTo(1);
    });
  }

  void _dispatchAction({
    required String actionKey,
    required FriendsEvent event,
  }) {
    if (_pendingActionKey != null || _isCreatingConversation) return;
    setState(() => _pendingActionKey = actionKey);
    HapticFeedback.lightImpact();
    _bloc.add(event);
  }

  bool _isActionPending(String actionKey) => _pendingActionKey == actionKey;

  void _clearPendingAction() {
    if (!mounted || _pendingActionKey == null) return;
    setState(() => _pendingActionKey = null);
  }

  String _pendingActionLabel(String? actionKey) {
    if (actionKey == null) return 'Mise a jour...';
    if (actionKey.startsWith('remove-')) return 'Suppression de l\'ami...';
    if (actionKey.startsWith('accept-')) return 'Validation de la demande...';
    if (actionKey.startsWith('reject-')) return 'Refus de la demande...';
    if (actionKey.startsWith('cancel-')) return 'Annulation de la demande...';
    if (actionKey.startsWith('send-')) return 'Envoi de la demande...';
    if (actionKey.startsWith('message-')) {
      return 'Ouverture de la conversation...';
    }
    return 'Mise a jour...';
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

  Future<void> _startConversation(String friendId, String friendName) async {
    if (_isCreatingConversation || _pendingActionKey != null) return;
    setState(() {
      _isCreatingConversation = true;
      _pendingActionKey = 'message-$friendId';
    });

    // Afficher un loader pendant la création de la conversation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Créer ou récupérer la conversation
      final getOrCreateConversation = getIt<GetOrCreateConversationUseCase>();
      final conversationId = await getOrCreateConversation.call(friendId);

      if (mounted) {
        // Fermer le loader
        Navigator.pop(context);
        setState(() {
          _isCreatingConversation = false;
          _pendingActionKey = null;
        });

        // Naviguer vers le chat
        context.pushNamed(
          'chatConversation',
          pathParameters: {'conversationId': conversationId},
        );
      }
    } catch (e) {
      if (mounted) {
        // Fermer le loader
        Navigator.pop(context);
        setState(() {
          _isCreatingConversation = false;
          _pendingActionKey = null;
        });

        // Afficher l'erreur
        _showFeedbackSnack(message: 'Erreur: ${e.toString()}', isError: true);
      }
    }
  }
}

class _FriendsBackground extends StatelessWidget {
  final Widget child;

  const _FriendsBackground({required this.child});

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

class _SearchStatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SearchStatusPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return Tooltip(
      message: 'Voir les demandes recues',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: pill,
        ),
      ),
    );
  }
}

class _FriendsHero extends StatelessWidget {
  final FriendsState state;

  const _FriendsHero({required this.state});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gere ton cercle',
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
                child: const Icon(Icons.group_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ajoute des contacts, accepte des demandes et demarre tes discussions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Amis',
                  value: '${state.friends.length}',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Recues',
                  value: '${state.receivedRequests.length}',
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Envoyees',
                  value: '${state.sentRequests.length}',
                  icon: Icons.send_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
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
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _FriendsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _FriendsEmptyState({
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
