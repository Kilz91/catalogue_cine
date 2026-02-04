import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_search_result_entity.dart';

/// Model pour les résultats de recherche d'utilisateurs
class UserSearchResultModel {
  final String userId;
  final String displayName;
  final String email;

  UserSearchResultModel({
    required this.userId,
    required this.displayName,
    required this.email,
  });

  /// Conversion depuis Firestore
  factory UserSearchResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSearchResultModel(
      userId: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
    );
  }

  /// Conversion vers Entity
  UserSearchResultEntity toEntity() {
    return UserSearchResultEntity(
      userId: userId,
      displayName: displayName,
      email: email,
    );
  }
}
