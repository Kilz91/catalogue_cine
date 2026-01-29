import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/error/exceptions.dart';

/// DataSource distant pour le profil utilisateur
abstract class ProfileRemoteDataSource {
  Future<User> getUserProfile();
  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  });
  Future<String> uploadProfileImage(String imagePath);
}

/// Implémentation avec Firebase
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> getUserProfile() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('Utilisateur non connecté');
      }

      // Récupérer les données depuis Firestore avec gestion du mode offline
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists) {
        // Si pas de document, créer un profil par défaut
        final user = User(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName,
          profileImageUrl: currentUser.photoURL,
          createdAt: currentUser.metadata.creationTime,
          isVerified: currentUser.emailVerified,
        );

        // Tenter de créer le document (ne réussira que si en ligne)
        try {
          await _firestore.collection('users').doc(currentUser.uid).set({
            'email': user.email,
            'displayName': user.displayName,
            'profileImageUrl': user.profileImageUrl,
            'bio': user.bio,
            'createdAt': user.createdAt?.toIso8601String(),
            'isVerified': user.isVerified,
          });
        } catch (e) {
          // Ignore l'erreur si offline, retourne le user par défaut
        }

        return user;
      }

      final data = doc.data()!;
      return User(
        id: currentUser.uid,
        email: data['email'] ?? currentUser.email ?? '',
        displayName: data['displayName'] ?? currentUser.displayName,
        profileImageUrl: data['profileImageUrl'] ?? currentUser.photoURL,
        bio: data['bio'],
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : currentUser.metadata.creationTime,
        isVerified: data['isVerified'] ?? currentUser.emailVerified,
      );
    } on UnauthorizedException {
      rethrow;
    } on FirebaseException catch (e) {
      // Gerer spécifiquement l'erreur offline
      if (e.code == 'unavailable' ||
          (e.message != null && e.message!.contains('offline'))) {
        // Retourner un profil par défaut en cas d'offline
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          return User(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName,
            profileImageUrl: currentUser.photoURL,
            createdAt: currentUser.metadata.creationTime,
            isVerified: currentUser.emailVerified,
          );
        }
      }
      throw AppException('Erreur Firestore: ${e.message ?? e.code}');
    } catch (e) {
      throw AppException(
        'Erreur lors de la récupération du profil: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw UnauthorizedException('Utilisateur non connecté');
      }

      // Mettre à jour Firebase Auth si displayName ou photo change
      if (displayName != null) {
        await currentUser.updateDisplayName(displayName);
      }
      if (profileImageUrl != null) {
        await currentUser.updatePhotoURL(profileImageUrl);
      }

      // Mettre à jour Firestore
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updateData);
      }

      // Récupérer et retourner le profil mis à jour
      return await getUserProfile();
    } on UnauthorizedException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AppException('Erreur Firestore: ${e.message ?? e.code}');
    } catch (e) {
      throw AppException(
        'Erreur lors de la mise à jour du profil: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      // TODO: Implémenter l'upload avec Firebase Storage
      // Pour l'instant, retourner un placeholder
      throw UnimplementedError(
        'Upload d\'image non implémenté. Utiliser Firebase Storage.',
      );
    } catch (e) {
      throw AppException('Erreur lors de l\'upload de l\'image: $e');
    }
  }
}
