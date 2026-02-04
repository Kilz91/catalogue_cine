import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/friends_usecases.dart';
import 'friends_event.dart';
import 'friends_state.dart';

/// BLoC pour la gestion des amis
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final GetFriendsUseCase getFriends;
  final GetReceivedFriendRequestsUseCase getReceivedRequests;
  final GetSentFriendRequestsUseCase getSentRequests;
  final SearchUsersUseCase searchUsers;
  final SendFriendRequestUseCase sendFriendRequest;
  final CancelFriendRequestUseCase cancelFriendRequest;
  final AcceptFriendRequestUseCase acceptFriendRequest;
  final RejectFriendRequestUseCase rejectFriendRequest;
  final RemoveFriendUseCase removeFriend;

  FriendsBloc({
    required this.getFriends,
    required this.getReceivedRequests,
    required this.getSentRequests,
    required this.searchUsers,
    required this.sendFriendRequest,
    required this.cancelFriendRequest,
    required this.acceptFriendRequest,
    required this.rejectFriendRequest,
    required this.removeFriend,
  }) : super(const FriendsState()) {
    on<LoadFriendsDataEvent>(_onLoadFriendsData);
    on<SearchUsersEvent>(_onSearchUsers);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<CancelFriendRequestEvent>(_onCancelFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<RejectFriendRequestEvent>(_onRejectFriendRequest);
    on<RemoveFriendEvent>(_onRemoveFriend);
  }

  Future<void> _onLoadFriendsData(
    LoadFriendsDataEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // Charger les amis
    final friendsResult = await getFriends();
    // Charger les demandes reçues
    final receivedResult = await getReceivedRequests();
    // Charger les demandes envoyées
    final sentResult = await getSentRequests();

    friendsResult.fold(
      (failure) {
        print('❌ ERREUR FRIENDS: ${failure.message}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (friends) {
        receivedResult.fold(
          (failure) {
            print('❌ ERREUR RECEIVED REQUESTS: ${failure.message}');
            emit(state.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ));
          },
          (received) {
            sentResult.fold(
              (failure) {
                print('❌ ERREUR SENT REQUESTS: ${failure.message}');
                emit(state.copyWith(
                  isLoading: false,
                  errorMessage: failure.message,
                ));
              },
              (sent) => emit(state.copyWith(
                isLoading: false,
                friends: friends,
                receivedRequests: received,
                sentRequests: sent,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<FriendsState> emit,
  ) async {
    if (event.query.isEmpty) {
      print('🔍 SEARCH: Query vide');
      emit(state.copyWith(searchResults: []));
      return;
    }

    print('🔍 SEARCH: Recherche pour "${event.query}"');
    final result = await searchUsers(event.query);

    result.fold(
      (failure) {
        print('❌ ERREUR SEARCH: ${failure.message}');
        emit(state.copyWith(
          searchResults: [],
          errorMessage: failure.message,
        ));
      },
      (results) {
        print('✅ SEARCH: ${results.length} résultats trouvés');
        results.forEach((user) => print('   - ${user.displayName} (${user.userId})'));
        emit(state.copyWith(
          searchResults: results,
        ));
      },
    );
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await sendFriendRequest(event.receiverId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Demande envoyée',
        ));
        // Recharger les données
        add(LoadFriendsDataEvent());
      },
    );
  }

  Future<void> _onCancelFriendRequest(
    CancelFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await cancelFriendRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Demande annulée',
        ));
        // Recharger les données
        add(LoadFriendsDataEvent());
      },
    );
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await acceptFriendRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Ami ajouté',
        ));
        // Recharger les données
        add(LoadFriendsDataEvent());
      },
    );
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await rejectFriendRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Demande refusée',
        ));
        // Recharger les données
        add(LoadFriendsDataEvent());
      },
    );
  }

  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await removeFriend(event.friendshipId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Ami supprimé',
        ));
        // Recharger les données
        add(LoadFriendsDataEvent());
      },
    );
  }
}
