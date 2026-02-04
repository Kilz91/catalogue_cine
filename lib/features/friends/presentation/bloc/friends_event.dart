import 'package:equatable/equatable.dart';

/// Events pour le BLoC Friends
abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les données (amis + demandes)
class LoadFriendsDataEvent extends FriendsEvent {}

/// Rechercher des utilisateurs
class SearchUsersEvent extends FriendsEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Envoyer une demande d'ami
class SendFriendRequestEvent extends FriendsEvent {
  final String receiverId;

  const SendFriendRequestEvent(this.receiverId);

  @override
  List<Object?> get props => [receiverId];
}

/// Annuler une demande envoyée
class CancelFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const CancelFriendRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Accepter une demande reçue
class AcceptFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const AcceptFriendRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Refuser une demande reçue
class RejectFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const RejectFriendRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Supprimer un ami
class RemoveFriendEvent extends FriendsEvent {
  final String friendshipId;

  const RemoveFriendEvent(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}
