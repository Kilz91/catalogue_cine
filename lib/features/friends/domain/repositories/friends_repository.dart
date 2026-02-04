import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend_request_entity.dart';
import '../entities/friendship_entity.dart';
import '../entities/user_search_result_entity.dart';

/// Repository abstrait pour la gestion des amis
abstract class FriendsRepository {
  /// Rechercher des utilisateurs par nom
  Future<Either<Failure, List<UserSearchResultEntity>>> searchUsers({
    required String query,
  });

  /// Envoyer une demande d'ami
  Future<Either<Failure, void>> sendFriendRequest({
    required String receiverId,
  });

  /// Annuler une demande d'ami envoyée
  Future<Either<Failure, void>> cancelFriendRequest({
    required String requestId,
  });

  /// Accepter une demande d'ami reçue
  Future<Either<Failure, void>> acceptFriendRequest({
    required String requestId,
  });

  /// Refuser une demande d'ami reçue
  Future<Either<Failure, void>> rejectFriendRequest({
    required String requestId,
  });

  /// Supprimer un ami (des deux côtés)
  Future<Either<Failure, void>> removeFriend({
    required String friendshipId,
  });

  /// Récupérer les demandes d'amis reçues (pending)
  Future<Either<Failure, List<FriendRequestEntity>>> getReceivedFriendRequests();

  /// Récupérer les demandes d'amis envoyées (pending)
  Future<Either<Failure, List<FriendRequestEntity>>> getSentFriendRequests();

  /// Récupérer la liste des amis
  Future<Either<Failure, List<FriendshipEntity>>> getFriends();
}
