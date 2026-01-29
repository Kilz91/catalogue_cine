/// Entité User (profil utilisateur)
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final String? bio;
  final DateTime? createdAt;
  final bool isVerified;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.bio,
    this.createdAt,
    this.isVerified = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? bio,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
