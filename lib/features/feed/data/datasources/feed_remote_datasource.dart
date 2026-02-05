import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/activity_model.dart';
import '../models/recommendation_model.dart';

/// DataSource pour le fil d'actualité (Firebase)
abstract class FeedRemoteDataSource {
  Future<List<ActivityModel>> getFeedActivities();
  Future<List<RecommendationModel>> getRecommendations();
  Future<void> logActivity({
    required String actionType,
    required String mediaId,
    required String mediaTitle,
    required String mediaPoster,
  });
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FeedRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  String get _currentUserId {
    final user = auth.currentUser;
    if (user == null) throw ServerException('Non authentifié');
    return user.uid;
  }

  @override
  Future<List<ActivityModel>> getFeedActivities() async {
    try {
      // Récupérer les amis de l'utilisateur
      final friendshipsSnapshot = await firestore
          .collection('friendships')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final friendIds = friendshipsSnapshot.docs
          .map((doc) => doc.data()['friendId'] as String)
          .toList();

      if (friendIds.isEmpty) {
        return [];
      }

      // Récupérer les activités de ces amis (dernières 50)
      final activitiesSnapshot = await firestore
          .collection('activities')
          .where('userId', whereIn: friendIds)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return activitiesSnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ FEED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RecommendationModel>> getRecommendations() async {
    try {
      // Pour l'instant, retourner des recommandations basées sur les genres populaires
      final recsSnapshot = await firestore
          .collection('recommendations')
          .orderBy('rating', descending: true)
          .limit(20)
          .get();

      return recsSnapshot.docs
          .map((doc) => RecommendationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ RECOMMENDATIONS ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logActivity({
    required String actionType,
    required String mediaId,
    required String mediaTitle,
    required String mediaPoster,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) throw ServerException('Non authentifié');

      // Récupérer les infos de l'utilisateur
      final userDoc = await firestore
          .collection('users')
          .doc(_currentUserId)
          .get();

      final userData = userDoc.data() ?? {};

      await firestore.collection('activities').add({
        'userId': _currentUserId,
        'userName': currentUser.displayName ?? 'Utilisateur',
        'userImage': currentUser.photoURL ?? '',
        'actionType': actionType,
        'mediaId': mediaId,
        'mediaTitle': mediaTitle,
        'mediaPoster': mediaPoster,
        'timestamp': Timestamp.now(),
      });

      print('✅ ACTIVITY LOGGED: $actionType on $mediaTitle');
    } catch (e) {
      print('❌ LOG ACTIVITY ERROR: $e');
      throw ServerException(e.toString());
    }
  }
}
