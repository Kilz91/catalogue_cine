import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/friend_request_model.dart';
import '../models/friendship_model.dart';
import '../models/user_search_result_model.dart';

/// DataSource pour la gestion des amis (Firebase)
abstract class FriendsRemoteDataSource {
  Future<List<UserSearchResultModel>> searchUsers({required String query});
  Future<void> sendFriendRequest({required String receiverId});
  Future<void> cancelFriendRequest({required String requestId});
  Future<void> acceptFriendRequest({required String requestId});
  Future<void> rejectFriendRequest({required String requestId});
  Future<void> removeFriend({required String friendshipId});
  Future<List<FriendRequestModel>> getReceivedFriendRequests();
  Future<List<FriendRequestModel>> getSentFriendRequests();
  Future<List<FriendshipModel>> getFriends();
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FriendsRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  String get _currentUserId {
    final user = auth.currentUser;
    if (user == null) throw ServerException('Non authentifié');
    return user.uid;
  }

  @override
  Future<List<UserSearchResultModel>> searchUsers({required String query}) async {
    try {
      if (query.isEmpty) return [];

      final queryLower = query.toLowerCase();
      
      print('🔥 FIRESTORE SEARCH: recherche de "$queryLower"');
      
      // Récupérer tous les users et filtrer en mémoire
      final snapshot = await firestore.collection('users').get();
      
      print('🔥 Total users: ${snapshot.docs.length}');
      
      final results = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final displayName = (data['displayName'] ?? '').toString().toLowerCase();
            final displayNameLower = (data['displayNameLower'] ?? '').toString().toLowerCase();
            
            // Chercher soit dans displayName soit dans displayNameLower
            final matches = displayName.contains(queryLower) || 
                           displayNameLower.contains(queryLower);
            
            if (matches) {
              print('   ✅ Match trouvé: ${data['displayName']} (${doc.id})');
            }
            
            return matches && doc.id != _currentUserId;
          })
          .map((doc) => UserSearchResultModel.fromFirestore(doc))
          .toList();
      
      print('🔥 Résultats: ${results.length} trouvés');
      return results;
    } catch (e) {
      print('❌ FIRESTORE ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendFriendRequest({required String receiverId}) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) throw ServerException('Non authentifié');

      // Ne pas envoyer de demande à soi-même
      if (receiverId == _currentUserId) {
        throw ServerException('Vous ne pouvez pas vous ajouter vous-même');
      }

      // Récupérer les infos du destinataire pour vérifier qu'il existe
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();

      if (!receiverDoc.exists) {
        throw ServerException('Utilisateur non trouvé');
      }

      // Vérifier si une demande existe déjà
      final existingRequest = await firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: _currentUserId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw ServerException('Demande déjà envoyée');
      }

      // Vérifier si déjà amis
      final existingFriendship = await firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .where('friendId', isEqualTo: receiverId)
          .get();

      if (existingFriendship.docs.isNotEmpty) {
        throw ServerException('Vous êtes déjà amis');
      }

      // Créer la demande avec les infos du destinataire
      final receiverData = receiverDoc.data() ?? {};
      final request = FriendRequestModel(
        id: '',
        senderId: _currentUserId,
        senderName: currentUser.displayName ?? 'Utilisateur',
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        receiverName: receiverData['displayName'] as String?,
        receiverEmail: receiverData['email'] as String?,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('friend_requests')
          .add(request.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelFriendRequest({required String requestId}) async {
    try {
      await firestore.collection('friend_requests').doc(requestId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> acceptFriendRequest({required String requestId}) async {
    try {
      final requestDoc = await firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw ServerException('Demande non trouvée');
      }

      final request = FriendRequestModel.fromFirestore(requestDoc);

      // Récupérer les infos du receiver (current user)
      final receiverDoc = await firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      final receiverData = receiverDoc.data() ?? {};

      // Créer deux documents d'amitié (un pour chaque utilisateur)
      final batch = firestore.batch();

      // Friendship pour le sender
      final friendship1 = FriendshipModel(
        id: '',
        userId: request.senderId,
        friendId: _currentUserId,
        friendName: receiverData['displayName'] ?? 'Utilisateur',
        friendEmail: receiverData['email'] ?? '',
        createdAt: DateTime.now(),
      );

      // Friendship pour le receiver (current user)
      final friendship2 = FriendshipModel(
        id: '',
        userId: _currentUserId,
        friendId: request.senderId,
        friendName: request.senderName,
        friendEmail: request.senderEmail,
        createdAt: DateTime.now(),
      );

      batch.set(
        firestore.collection('friendships').doc(),
        friendship1.toFirestore(),
      );
      batch.set(
        firestore.collection('friendships').doc(),
        friendship2.toFirestore(),
      );

      // Supprimer la demande
      batch.delete(firestore.collection('friend_requests').doc(requestId));

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectFriendRequest({required String requestId}) async {
    try {
      await firestore.collection('friend_requests').doc(requestId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFriend({required String friendshipId}) async {
    try {
      // Récupérer l'amitié pour savoir qui sont les deux users
      final friendshipDoc = await firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (!friendshipDoc.exists) {
        throw ServerException('Amitié non trouvée');
      }

      final friendship = FriendshipModel.fromFirestore(friendshipDoc);

      // Trouver l'amitié réciproque
      final reciprocalQuery = await firestore
          .collection('friendships')
          .where('userId', isEqualTo: friendship.friendId)
          .where('friendId', isEqualTo: friendship.userId)
          .get();

      // Supprimer les deux amitiés
      final batch = firestore.batch();
      batch.delete(firestore.collection('friendships').doc(friendshipId));
      
      for (final doc in reciprocalQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendRequestModel>> getReceivedFriendRequests() async {
    try {
      final snapshot = await firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendRequestModel>> getSentFriendRequests() async {
    try {
      final snapshot = await firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendshipModel>> getFriends() async {
    try {
      final snapshot = await firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendshipModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
