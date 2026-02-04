/// Entity représentant un résultat de recherche d'utilisateur
class UserSearchResultEntity {
  final String userId;
  final String displayName;
  final String email;

  const UserSearchResultEntity({
    required this.userId,
    required this.displayName,
    required this.email,
  });
}
