// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    ProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaId: (json['media_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      currentSeason: (json['current_season'] as num?)?.toInt() ?? 0,
      currentEpisode: (json['current_episode'] as num?)?.toInt() ?? 0,
      totalEpisodes: (json['total_episodes'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'media_id': instance.mediaId,
      'media_type': instance.mediaType,
      'current_season': instance.currentSeason,
      'current_episode': instance.currentEpisode,
      'total_episodes': instance.totalEpisodes,
      'percentage': instance.percentage,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };
