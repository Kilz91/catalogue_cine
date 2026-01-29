/// Entité Actor pour les acteurs/actrices
class Actor {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final DateTime? birthDate;
  final String? birthPlace;
  final List<String>? knownFor;

  Actor({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthDate,
    this.birthPlace,
    this.knownFor,
  });

  Actor copyWith({
    int? id,
    String? name,
    String? profilePath,
    String? biography,
    DateTime? birthDate,
    String? birthPlace,
    List<String>? knownFor,
  }) {
    return Actor(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePath: profilePath ?? this.profilePath,
      biography: biography ?? this.biography,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      knownFor: knownFor ?? this.knownFor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Actor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
