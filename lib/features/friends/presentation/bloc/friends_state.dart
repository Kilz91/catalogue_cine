import 'package:equatable/equatable.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/entities/user_search_result_entity.dart';

/// States pour le BLoC Friends
class FriendsState extends Equatable {
  final bool isLoading;
  final List<FriendshipEntity> friends;
  final List<FriendRequestEntity> receivedRequests;
  final List<FriendRequestEntity> sentRequests;
  final List<UserSearchResultEntity> searchResults;
  final String? errorMessage;
  final String? successMessage;

  const FriendsState({
    this.isLoading = false,
    this.friends = const [],
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.searchResults = const [],
    this.errorMessage,
    this.successMessage,
  });

  FriendsState copyWith({
    bool? isLoading,
    List<FriendshipEntity>? friends,
    List<FriendRequestEntity>? receivedRequests,
    List<FriendRequestEntity>? sentRequests,
    List<UserSearchResultEntity>? searchResults,
    String? errorMessage,
    String? successMessage,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        friends,
        receivedRequests,
        sentRequests,
        searchResults,
        errorMessage,
        successMessage,
      ];
}
