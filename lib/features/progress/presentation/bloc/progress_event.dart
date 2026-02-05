part of 'progress_bloc.dart';

abstract class ProgressEvent {}

class LoadProgressEvent extends ProgressEvent {
  final int mediaId;
  final String mediaType;

  LoadProgressEvent({
    required this.mediaId,
    required this.mediaType,
  });
}

class UpdateProgressEvent extends ProgressEvent {
  final int mediaId;
  final String mediaType;
  final int currentSeason;
  final int currentEpisode;
  final int totalEpisodes;
  final double percentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? mediaTitle;
  final String? mediaPoster;
  final bool shouldLogActivity; // true = validation explicite, false = mise à jour slider

  UpdateProgressEvent({
    required this.mediaId,
    required this.mediaType,
    required this.currentSeason,
    required this.currentEpisode,
    required this.totalEpisodes,
    required this.percentage,
    this.startDate,
    this.endDate,
    this.mediaTitle,
    this.mediaPoster,
    this.shouldLogActivity = false,
  });
}
