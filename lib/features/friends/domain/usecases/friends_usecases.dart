import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend_request_entity.dart';
import '../entities/friendship_entity.dart';
import '../entities/user_search_result_entity.dart';
import '../repositories/friends_repository.dart';

/// Use case pour rechercher des utilisateurs
class SearchUsersUseCase {
  final FriendsRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<Failure, List<UserSearchResultEntity>>> call(String query) {
    return repository.searchUsers(query: query);
  }
}

/// Use case pour envoyer une demande d'ami
class SendFriendRequestUseCase {
  final FriendsRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String receiverId) {
    return repository.sendFriendRequest(receiverId: receiverId);
  }
}

/// Use case pour annuler une demande d'ami
class CancelFriendRequestUseCase {
  final FriendsRepository repository;

  CancelFriendRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) {
    return repository.cancelFriendRequest(requestId: requestId);
  }
}

/// Use case pour accepter une demande d'ami
class AcceptFriendRequestUseCase {
  final FriendsRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) {
    return repository.acceptFriendRequest(requestId: requestId);
  }
}

/// Use case pour refuser une demande d'ami
class RejectFriendRequestUseCase {
  final FriendsRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) {
    return repository.rejectFriendRequest(requestId: requestId);
  }
}

/// Use case pour supprimer un ami
class RemoveFriendUseCase {
  final FriendsRepository repository;

  RemoveFriendUseCase(this.repository);

  Future<Either<Failure, void>> call(String friendshipId) {
    return repository.removeFriend(friendshipId: friendshipId);
  }
}

/// Use case pour récupérer les demandes reçues
class GetReceivedFriendRequestsUseCase {
  final FriendsRepository repository;

  GetReceivedFriendRequestsUseCase(this.repository);

  Future<Either<Failure, List<FriendRequestEntity>>> call() {
    return repository.getReceivedFriendRequests();
  }
}

/// Use case pour récupérer les demandes envoyées
class GetSentFriendRequestsUseCase {
  final FriendsRepository repository;

  GetSentFriendRequestsUseCase(this.repository);

  Future<Either<Failure, List<FriendRequestEntity>>> call() {
    return repository.getSentFriendRequests();
  }
}

/// Use case pour récupérer la liste des amis
class GetFriendsUseCase {
  final FriendsRepository repository;

  GetFriendsUseCase(this.repository);

  Future<Either<Failure, List<FriendshipEntity>>> call() {
    return repository.getFriends();
  }
}
