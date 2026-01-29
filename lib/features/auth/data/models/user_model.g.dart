// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  bio: json['bio'] as String?,
  createdAt: _dateTimeFromJson(json['createdAt']),
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'profileImageUrl': instance.profileImageUrl,
  'bio': instance.bio,
  'createdAt': _dateTimeToJson(instance.createdAt),
  'isVerified': instance.isVerified,
};
