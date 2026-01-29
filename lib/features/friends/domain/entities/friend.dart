import 'package:catalogue_cine/features/auth/domain/entities/user.dart';

/// Entité pour un amis
class Friend {
  final String id;
  final String userId;
  final String friendId;
  final User friendUser;
  final DateTime dateAdded;
  final String status; // 'pending', 'accepted', 'blocked'

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendUser,
    required this.dateAdded,
    this.status = 'accepted',
  });

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    User? friendUser,
    DateTime? dateAdded,
    String? status,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendUser: friendUser ?? this.friendUser,
      dateAdded: dateAdded ?? this.dateAdded,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friend && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
