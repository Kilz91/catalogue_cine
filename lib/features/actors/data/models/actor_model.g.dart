// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActorModel _$ActorModelFromJson(Map<String, dynamic> json) => ActorModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  profilePath: json['profile_path'] as String?,
  biography: json['biography'] as String?,
  birthDate: json['birthday'] as String?,
  birthPlace: json['place_of_birth'] as String?,
  knownFor: (json['known_for'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  character: json['character'] as String?,
);

Map<String, dynamic> _$ActorModelToJson(ActorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profile_path': instance.profilePath,
      'biography': instance.biography,
      'birthday': instance.birthDate,
      'place_of_birth': instance.birthPlace,
      'known_for': instance.knownFor,
      'character': instance.character,
    };
