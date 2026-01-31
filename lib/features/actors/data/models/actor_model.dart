import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/actor.dart';

part 'actor_model.g.dart';

@JsonSerializable()
class ActorModel {
  final int id;
  final String name;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final String? biography;
  @JsonKey(name: 'birthday')
  final String? birthDate;
  @JsonKey(name: 'place_of_birth')
  final String? birthPlace;
  @JsonKey(name: 'known_for')
  final List<String>? knownFor;
  @JsonKey(name: 'character')
  final String? character; // Pour le cast d'un média

  ActorModel({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthDate,
    this.birthPlace,
    this.knownFor,
    this.character,
  });

  factory ActorModel.fromJson(Map<String, dynamic> json) =>
      _$ActorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActorModelToJson(this);

  /// Convertir le model en entité
  Actor toEntity() {
    return Actor(
      id: id,
      name: name,
      profilePath: profilePath,
      biography: biography,
      birthDate: birthDate != null ? DateTime.tryParse(birthDate!) : null,
      birthPlace: birthPlace,
      knownFor: knownFor,
    );
  }

  /// Créer un model depuis une entité
  factory ActorModel.fromEntity(Actor actor) {
    return ActorModel(
      id: actor.id,
      name: actor.name,
      profilePath: actor.profilePath,
      biography: actor.biography,
      birthDate: actor.birthDate?.toIso8601String(),
      birthPlace: actor.birthPlace,
      knownFor: actor.knownFor,
    );
  }
}
