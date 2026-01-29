import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Modèle JSON de User (générée avec Freezed après)
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final String? bio;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.bio,
    this.createdAt,
    this.isVerified = false,
  });

  // Convertir vers l'entité domain
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      bio: bio,
      createdAt: createdAt,
      isVerified: isVerified,
    );
  }

  // Créer depuis l'entité domain
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      profileImageUrl: entity.profileImageUrl,
      bio: entity.bio,
      createdAt: entity.createdAt,
      isVerified: entity.isVerified,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

// Helpers pour la sérialisation de DateTime
DateTime? _dateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
  if (json is String) return DateTime.parse(json);
  return null;
}

dynamic _dateTimeToJson(DateTime? date) {
  return date?.toIso8601String();
}
