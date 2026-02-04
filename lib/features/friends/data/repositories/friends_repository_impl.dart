import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/entities/user_search_result_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_datasource.dart';

/// Implémentation du repository Friends
class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserSearchResultEntity>>> searchUsers({
    required String query,
  }) async {
    try {
      final models = await remoteDataSource.searchUsers(query: query);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest({
    required String receiverId,
  }) async {
    try {
      await remoteDataSource.sendFriendRequest(receiverId: receiverId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelFriendRequest({
    required String requestId,
  }) async {
    try {
      await remoteDataSource.cancelFriendRequest(requestId: requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest({
    required String requestId,
  }) async {
    try {
      await remoteDataSource.acceptFriendRequest(requestId: requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest({
    required String requestId,
  }) async {
    try {
      await remoteDataSource.rejectFriendRequest(requestId: requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend({
    required String friendshipId,
  }) async {
    try {
      await remoteDataSource.removeFriend(friendshipId: friendshipId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>>
      getReceivedFriendRequests() async {
    try {
      final models = await remoteDataSource.getReceivedFriendRequests();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>>
      getSentFriendRequests() async {
    try {
      final models = await remoteDataSource.getSentFriendRequests();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendshipEntity>>> getFriends() async {
    try {
      final models = await remoteDataSource.getFriends();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
