import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'progress_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProgressModel {
  final String id;
  final String userId;
  final int mediaId;
  final String mediaType;
  final int currentSeason;
  final int currentEpisode;
  final int totalEpisodes;
  final double percentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastUpdated;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    this.currentSeason = 0,
    this.currentEpisode = 0,
    this.totalEpisodes = 0,
    this.percentage = 0.0,
    this.startDate,
    this.endDate,
    this.lastUpdated,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  factory ProgressModel.fromFirestore(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaId: (json['media_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      currentSeason: (json['current_season'] as num?)?.toInt() ?? 0,
      currentEpisode: (json['current_episode'] as num?)?.toInt() ?? 0,
      totalEpisodes: (json['total_episodes'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      lastUpdated: parseDate(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);
}
