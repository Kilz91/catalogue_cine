import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../models/media_model.dart';
import '../models/user_media_model.dart';

/// DataSource Firestore pour le catalogue
abstract class CatalogRemoteDataSource {
  Future<List<UserMediaModel>> getUserCatalog({String? status});
  Future<UserMediaModel> addToCatalog({
    required MediaModel media,
    required String status,
  });
  Future<UserMediaModel> updateStatus({
    required String userMediaId,
    required String status,
  });
  Future<void> removeFromCatalog(String userMediaId);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CatalogRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _catalogCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('catalog');
  }

  @override
  Future<List<UserMediaModel>> getUserCatalog({String? status}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw UnauthorizedException('Utilisateur non connecté');

    Query<Map<String, dynamic>> query = _catalogCollection(user.uid);

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('dateAdded', descending: true);

    final snapshot = await query.get(
      const GetOptions(source: Source.serverAndCache),
    );

    return snapshot.docs.map(UserMediaModel.fromFirestore).toList();
  }

  @override
  Future<UserMediaModel> addToCatalog({
    required MediaModel media,
    required String status,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw UnauthorizedException('Utilisateur non connecté');

    final collection = _catalogCollection(user.uid);

    // Vérifier si le média existe déjà
    final existing = await collection
        .where('mediaId', isEqualTo: media.id)
        .where('mediaType', isEqualTo: media.type)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final updateData = _buildStatusUpdate(status, doc.data());
      await doc.reference.update(updateData);
      final refreshed = await doc.reference.get();
      return UserMediaModel.fromFirestore(refreshed);
    }

    final docRef = collection.doc();
    final now = DateTime.now();

    final model = UserMediaModel(
      id: docRef.id,
      userId: user.uid,
      mediaId: media.id,
      mediaType: media.type,
      status: status,
      media: media,
      dateAdded: now,
      dateStarted: status == 'watching' ? now : null,
      dateCompleted: status == 'completed' ? now : null,
    );

    await docRef.set(model.toJson());
    return model;
  }

  @override
  Future<UserMediaModel> updateStatus({
    required String userMediaId,
    required String status,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw UnauthorizedException('Utilisateur non connecté');

    final docRef = _catalogCollection(user.uid).doc(userMediaId);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw NotFoundException('Média introuvable');
    }

    final updateData = _buildStatusUpdate(status, doc.data());
    await docRef.update(updateData);
    final refreshed = await docRef.get();
    return UserMediaModel.fromFirestore(refreshed);
  }

  @override
  Future<void> removeFromCatalog(String userMediaId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw UnauthorizedException('Utilisateur non connecté');

    await _catalogCollection(user.uid).doc(userMediaId).delete();
  }

  Map<String, dynamic> _buildStatusUpdate(
    String status,
    Map<String, dynamic>? existing,
  ) {
    final updateData = <String, dynamic>{'status': status};
    final now = DateTime.now().toIso8601String();

    if (status == 'watching') {
      if (existing == null || existing['dateStarted'] == null) {
        updateData['dateStarted'] = now;
      }
    }

    if (status == 'completed') {
      if (existing == null || existing['dateCompleted'] == null) {
        updateData['dateCompleted'] = now;
      }
    }

    return updateData;
  }
}
