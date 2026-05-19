import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

/// DataSource pour le chat (temps réel avec Firestore)
abstract class ChatRemoteDataSource {
  Stream<List<ChatConversationModel>> getConversations();
  Stream<List<ChatMessageModel>> getMessages(String conversationId);
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<String> getOrCreateConversation(String friendId);
  Future<void> markMessagesAsRead(String conversationId);
  Future<void> deleteConversationForMe(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRemoteDataSourceImpl({required this.firestore, required this.auth});

  String get _currentUserId {
    final user = auth.currentUser;
    if (user == null) throw ServerException('Non authentifié');
    return user.uid;
  }

  @override
  Stream<List<ChatConversationModel>> getConversations() {
    try {
      return firestore
          .collection('conversations')
          .where('participantIds', arrayContains: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatConversationModel.fromFirestore(doc))
                .where(
                  (conversation) =>
                      !conversation.deletedForUserIds.contains(_currentUserId),
                )
                .toList();
          });
    } catch (e) {
      debugPrint('❌ CONVERSATIONS ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ChatMessageModel>> getMessages(String conversationId) {
    try {
      return firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatMessageModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      debugPrint('❌ MESSAGES ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) throw ServerException('Non authentifié');

      final convRef = firestore.collection('conversations').doc(conversationId);
      final convDoc = await convRef.get();
      if (!convDoc.exists) {
        throw ServerException('Conversation introuvable');
      }

      final convData = convDoc.data() ?? {};
      final participantIds =
          (convData['participantIds'] as List?)?.cast<String>() ?? [];

      if (!participantIds.contains(_currentUserId)) {
        throw ServerException(
          'Vous ne pouvez pas envoyer de messages dans cette conversation',
        );
      }

      final otherParticipantId = participantIds.firstWhere(
        (id) => id != _currentUserId,
        orElse: () => '',
      );

      if (otherParticipantId.isEmpty) {
        throw ServerException('Conversation invalide');
      }

      if (convData['isMessagingAllowed'] == false) {
        throw ServerException(
          'Vous ne pouvez plus envoyer de messages a cette personne car vous n\'etes plus amis',
        );
      }

      // Double validation metier: si l'amitie n'existe plus, on bloque l'envoi
      // et on verrouille la conversation en lecture seule pour les deux parties.
      final friendshipSnapshot = await firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .where('friendId', isEqualTo: otherParticipantId)
          .limit(1)
          .get();

      if (friendshipSnapshot.docs.isEmpty) {
        await convRef.update({'isMessagingAllowed': false});
        throw ServerException(
          'Vous ne pouvez plus envoyer de messages a cette personne car vous n\'etes plus amis',
        );
      }

      final message = ChatMessageModel(
        id: '',
        conversationId: conversationId,
        senderId: _currentUserId,
        senderName: currentUser.displayName ?? 'Utilisateur',
        senderImage: currentUser.photoURL ?? '',
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Ajouter le message
      await firestore.collection('messages').add(message.toJson());

      final unreadCount = Map<String, int>.from(
        (convData['unreadCount'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), (value as num).toInt()),
            ) ??
            {},
      );

      // Incrémenter le compteur de non-lus pour les autres participants
      for (final participantId in participantIds) {
        if (participantId != _currentUserId) {
          unreadCount[participantId] = (unreadCount[participantId] ?? 0) + 1;
        }
      }

      // Mettre à jour la conversation
      await convRef.update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSenderId': _currentUserId,
        'unreadCount': unreadCount,
        'isMessagingAllowed': true,
        'deletedFor': FieldValue.arrayRemove(participantIds),
      });

      debugPrint('✅ MESSAGE SENT');
    } catch (e) {
      debugPrint('❌ SEND MESSAGE ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> getOrCreateConversation(String friendId) async {
    try {
      // Chercher une conversation existante entre les deux utilisateurs
      final existingConvs = await firestore
          .collection('conversations')
          .where('participantIds', arrayContains: _currentUserId)
          .get();

      for (var doc in existingConvs.docs) {
        final participantIds =
            (doc.data()['participantIds'] as List?)?.cast<String>() ?? [];
        if (participantIds.contains(friendId) && participantIds.length == 2) {
          await doc.reference.update({
            'deletedFor': FieldValue.arrayRemove([_currentUserId]),
          });
          return doc.id;
        }
      }

      // Si pas de conversation existante, en créer une nouvelle
      final currentUser = auth.currentUser;
      if (currentUser == null) throw ServerException('Non authentifié');

      // Récupérer les infos de l'ami
      final friendDoc = await firestore.collection('users').doc(friendId).get();
      final friendData = friendDoc.data() ?? {};

      final conversation = ChatConversationModel(
        id: '',
        participantIds: [_currentUserId, friendId],
        participantNames: {
          _currentUserId: currentUser.displayName ?? 'Utilisateur',
          friendId: friendData['displayName'] ?? 'Utilisateur',
        },
        participantImages: {
          _currentUserId: currentUser.photoURL ?? '',
          friendId: friendData['photoURL'] ?? '',
        },
        isMessagingAllowed: true,
        deletedForUserIds: const [],
        lastMessage: null,
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: null,
        unreadCount: {_currentUserId: 0, friendId: 0},
      );

      final docRef = await firestore
          .collection('conversations')
          .add(conversation.toJson());

      debugPrint('✅ CONVERSATION CREATED: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ CREATE CONVERSATION ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      // Récupérer la conversation
      final convDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (convDoc.exists) {
        final unreadCount = Map<String, int>.from(
          (convDoc.data()?['unreadCount'] as Map?)?.map(
                (key, value) => MapEntry(key.toString(), value as int),
              ) ??
              {},
        );

        // Réinitialiser le compteur pour l'utilisateur actuel
        unreadCount[_currentUserId] = 0;

        await firestore.collection('conversations').doc(conversationId).update({
          'unreadCount': unreadCount,
        });
      }

      // Marquer tous les messages de la conversation comme lus pour l'utilisateur actuel
      final messages = await firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: _currentUserId)
          .get();

      final batch = firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      debugPrint('✅ MESSAGES MARKED AS READ');
    } catch (e) {
      debugPrint('❌ MARK AS READ ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteConversationForMe(String conversationId) async {
    try {
      final convRef = firestore.collection('conversations').doc(conversationId);
      final convDoc = await convRef.get();

      if (!convDoc.exists) {
        throw ServerException('Conversation introuvable');
      }

      final convData = convDoc.data() ?? {};
      final participantIds =
          (convData['participantIds'] as List?)?.cast<String>() ?? [];

      if (!participantIds.contains(_currentUserId)) {
        throw ServerException('Acces refuse a cette conversation');
      }

      await convRef.update({
        'deletedFor': FieldValue.arrayUnion([_currentUserId]),
        'unreadCount.$_currentUserId': 0,
      });

      debugPrint('✅ CONVERSATION DELETED FOR CURRENT USER');
    } catch (e) {
      debugPrint('❌ DELETE CONVERSATION ERROR: $e');
      throw ServerException(e.toString());
    }
  }
}
