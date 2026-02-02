import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/progress_model.dart';

abstract class ProgressRemoteDataSource {
  Future<ProgressModel> getMediaProgress({
    required int mediaId,
    required String mediaType,
  });

  Future<void> updateProgress({
    required int mediaId,
    required String mediaType,
    required int currentSeason,
    required int currentEpisode,
    required int totalEpisodes,
    required double percentage,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ProgressModel> createProgress({
    required int mediaId,
    required String mediaType,
    required int totalEpisodes,
  });

  Future<List<ProgressModel>> getUserProgressList();

  Future<void> deleteProgress({required int mediaId});
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProgressRemoteDataSourceImpl(
    this._firestore,
    this._auth,
  );

  String get _userId => _auth.currentUser!.uid;

  @override
  Future<ProgressModel> getMediaProgress({
    required int mediaId,
    required String mediaType,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc(mediaId.toString())
          .get();

      if (!doc.exists) {
        throw Exception('Progression non trouvée');
      }

      return ProgressModel.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la progression: $e');
    }
  }

  @override
  Future<void> updateProgress({
    required int mediaId,
    required String mediaType,
    required int currentSeason,
    required int currentEpisode,
    required int totalEpisodes,
    required double percentage,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc(mediaId.toString())
          .set({
        'id': mediaId.toString(),
        'user_id': _userId,
        'media_id': mediaId,
        'media_type': mediaType,
        'current_season': currentSeason,
        'current_episode': currentEpisode,
        'total_episodes': totalEpisodes,
        'percentage': percentage,
        'start_date': startDate,
        'end_date': endDate,
        'last_updated': DateTime.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la progression: $e');
    }
  }

  @override
  Future<ProgressModel> createProgress({
    required int mediaId,
    required String mediaType,
    required int totalEpisodes,
  }) async {
    try {
      final progressId = mediaId.toString();
      final now = DateTime.now();

      final progressData = {
        'id': progressId,
        'user_id': _userId,
        'media_id': mediaId,
        'media_type': mediaType,
        'current_season': 0,
        'current_episode': 0,
        'total_episodes': totalEpisodes,
        'percentage': 0.0,
        'start_date': now,
        'end_date': null,
        'last_updated': now,
      };

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc(progressId)
          .set(progressData);

      return ProgressModel.fromFirestore(progressData);
    } catch (e) {
      throw Exception('Erreur lors de la création de la progression: $e');
    }
  }

  @override
  Future<List<ProgressModel>> getUserProgressList() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .orderBy('last_updated', descending: true)
          .get();

        return snapshot.docs
          .map((doc) => ProgressModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des progressions: $e');
    }
  }

  @override
  Future<void> deleteProgress({required int mediaId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress')
          .doc(mediaId.toString())
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la progression: $e');
    }
  }
}
