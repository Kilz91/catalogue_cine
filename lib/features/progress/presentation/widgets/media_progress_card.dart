import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../catalog/presentation/bloc/catalog_event.dart';
import '../../../catalog/presentation/bloc/catalog_state.dart';
import '../../domain/entities/progress_entity.dart';
import '../bloc/progress_bloc.dart';

/// Widget pour afficher et gérer le suivi de progression depuis les détails du média
class MediaProgressCard extends StatefulWidget {
  final int mediaId;
  final String mediaType;
  final int totalEpisodes;
  final int totalSeasons;
  final int? episodeDurationMinutes;
  final String? mediaTitle;
  final String? mediaPoster;

  const MediaProgressCard({
    super.key,
    required this.mediaId,
    required this.mediaType,
    required this.totalEpisodes,
    this.totalSeasons = 1,
    this.episodeDurationMinutes,
    this.mediaTitle,
    this.mediaPoster,
  });

  @override
  State<MediaProgressCard> createState() => _MediaProgressCardState();
}

class _MediaProgressCardState extends State<MediaProgressCard> {
  bool _loadedCompleted = false;
  bool _loadedPlanned = false;
  late ProgressBloc _progressBloc;
  late CatalogBloc _catalogBloc;
  int _selectedSeason = 1;
  int _selectedEpisode = 1;
  double _progressPercent = 0.0;
  String _lastProgressKey = '';
  bool _isEditing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _userMediaId;

  @override
  void initState() {
    super.initState();
    _progressBloc = getIt<ProgressBloc>()
      ..add(LoadProgressEvent(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
      ));
    _catalogBloc = getIt<CatalogBloc>()
      ..add(LoadCatalogEvent('watching'));
  }

  @override
  void dispose() {
    _progressBloc.close();
    _catalogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      bloc: _catalogBloc,
      builder: (context, catalogState) {
        // Trouver le média dans le catalogue
        dynamic catalogItem;
        for (final item in catalogState.catalog) {
          if (item.media.id == widget.mediaId) {
            catalogItem = item;
            _userMediaId = item.id;
            break;
          }
        }

        if (catalogItem == null &&
            !_loadedCompleted &&
            !catalogState.isLoading &&
            catalogState.statusFilter == 'watching') {
          _loadedCompleted = true;
          _catalogBloc.add(LoadCatalogEvent('completed'));
        }

        if (catalogItem == null &&
            _loadedCompleted &&
            !_loadedPlanned &&
            !catalogState.isLoading &&
            catalogState.statusFilter == 'completed') {
          _loadedPlanned = true;
          _catalogBloc.add(LoadCatalogEvent('planned'));
        }

          // Vérifier le statut
            final canTrackProgress = catalogItem != null &&
              (catalogItem.status == 'watching' ||
                catalogItem.status == 'completed');

          if (!canTrackProgress) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      catalogItem == null
                          ? 'Ajoutez ce média à votre catalogue pour suivre votre progression'
                          : 'Changez le statut en "En cours" pour suivre votre progression',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return BlocBuilder<ProgressBloc, ProgressState>(
            bloc: _progressBloc,
            builder: (context, state) {
              if (state.progress != null) {
                _syncFromProgress(state.progress!);
              }
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Suivi de progression',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(_isEditing ? Icons.close : Icons.edit),
                            onPressed: () {
                              setState(() => _isEditing = !_isEditing);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.progress == null)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Demander la date de début
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              
                              if (selectedDate != null) {
                                // Créer une nouvelle progression avec la date choisie
                                _progressBloc.add(
                                  UpdateProgressEvent(
                                    mediaId: widget.mediaId,
                                    mediaType: widget.mediaType,
                                    currentSeason: 1,
                                    currentEpisode: 1,
                                    totalEpisodes: widget.totalEpisodes,
                                    percentage: 0.0,
                                    startDate: selectedDate,
                                    endDate: null,
                                    mediaTitle: widget.mediaTitle,
                                    mediaPoster: widget.mediaPoster,
                                  ),
                                );
                                // Activer le mode édition automatiquement
                                setState(() {
                                  _isEditing = true;
                                  _startDate = selectedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Commencer le suivi'),
                          ),
                        )
                      else ...[
                        _ProgressDisplay(progress: state.progress!),
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          _buildQuickControls(state.progress!),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () {
                                // Appliquer les changements de date de fin
                                _applyQuickUpdate(
                                  progress: state.progress!,
                                  endDate: _endDate,
                                  shouldLogActivity: true, // Logger l'activité lors de la validation
                                );

                                // Changer le statut en "completed" si date de fin définie
                                if (_endDate != null && _userMediaId != null) {
                                  _catalogBloc.add(
                                    UpdateCatalogStatusEvent(
                                      userMediaId: _userMediaId!,
                                      status: 'completed',
                                    ),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Média déplacé dans "Terminé"'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }

                                setState(() => _isEditing = false);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Valider'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
        );
      },
    );
  }

  void _syncFromProgress(ProgressEntity progress) {
    final key = '${progress.currentSeason}-${progress.currentEpisode}-'
        '${progress.percentage.toStringAsFixed(1)}-${progress.totalEpisodes}';
    if (key == _lastProgressKey) return;
    _lastProgressKey = key;

    final maxSeasons = widget.totalSeasons <= 0 ? 1 : widget.totalSeasons;
    final maxEpisodes = widget.totalEpisodes <= 0 ? 1 : widget.totalEpisodes;

    _selectedSeason = (progress.currentSeason <= 0 ? 1 : progress.currentSeason)
        .clamp(1, maxSeasons);
    _selectedEpisode =
        (progress.currentEpisode <= 0 ? 1 : progress.currentEpisode)
            .clamp(1, maxEpisodes);
    _progressPercent = progress.percentage.clamp(0.0, 100.0);
    _startDate = progress.startDate;
    _endDate = progress.endDate;
  }

  Widget _buildQuickControls(ProgressEntity progress) {
    final isSeries = widget.mediaType != 'movie';
    final maxSeasons = widget.totalSeasons <= 0 ? 1 : widget.totalSeasons;
    final maxEpisodes = widget.totalEpisodes <= 0 ? 1 : widget.totalEpisodes;
    final seasonOptions = List<int>.generate(maxSeasons, (i) => i + 1);
    final episodeOptions = List<int>.generate(maxEpisodes, (i) => i + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date de début
        if (_startDate == null) ...[
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quand avez-vous commencé à regarder ?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectStartDate(progress),
                    child: const Text('Choisir'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (isSeries) ...[
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _selectedEpisode > 1
                    ? () => _applyQuickUpdate(
                          progress: progress,
                          episode: _selectedEpisode - 1,
                        )
                    : null,
              ),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedSeason,
                  decoration: const InputDecoration(
                    labelText: 'Saison',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: seasonOptions
                      .map(
                        (season) => DropdownMenuItem(
                          value: season,
                          child: Text('S$season'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final newSeason = value ?? 1;
                    setState(() => _selectedSeason = newSeason);
                    _applyQuickUpdate(
                      progress: progress,
                      season: newSeason,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedEpisode,
                  decoration: const InputDecoration(
                    labelText: 'Épisode',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: episodeOptions
                      .map(
                        (episode) => DropdownMenuItem(
                          value: episode,
                          child: Text('E$episode'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final newEpisode = value ?? 1;
                    setState(() => _selectedEpisode = newEpisode);
                    _applyQuickUpdate(
                      progress: progress,
                      episode: newEpisode,
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _selectedEpisode < maxEpisodes
                    ? () => _applyQuickUpdate(
                          progress: progress,
                          episode: _selectedEpisode + 1,
                        )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Date de fin si complété
        if (_selectedEpisode >= maxEpisodes && _progressPercent >= 100.0) ...[
          ListTile(
            leading: const Icon(Icons.event_available, color: Colors.green),
            title: const Text('Date de fin'),
            subtitle: Text(
              _endDate != null
                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                  : 'Non définie',
            ),
            trailing: TextButton(
              onPressed: () => _selectEndDate(progress),
              child: const Text('Choisir'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progression rapide',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${_progressPercent.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Slider(
          value: _progressPercent,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${_progressPercent.toStringAsFixed(0)}%',
          onChanged: (value) => setState(() => _progressPercent = value),
          onChangeEnd: (value) => _applyQuickUpdate(
            progress: progress,
            percentage: value,
          ),
        ),
      ],
    );
  }

  void _applyQuickUpdate({
    required ProgressEntity progress,
    int? season,
    int? episode,
    double? percentage,
    DateTime? startDate,
    DateTime? endDate,
    bool shouldLogActivity = false, // true lors de la validation explicite
  }) {
    final maxSeasons = widget.totalSeasons <= 0 ? 1 : widget.totalSeasons;
    final maxEpisodes = widget.totalEpisodes <= 0 ? 1 : widget.totalEpisodes;

    final newSeason =
        (season ?? _selectedSeason).clamp(1, maxSeasons);
    final newEpisode =
        (episode ?? _selectedEpisode).clamp(1, maxEpisodes);
    final newPercentage =
        (percentage ?? _progressPercent).clamp(0.0, 100.0);

    setState(() {
      _selectedSeason = newSeason;
      _selectedEpisode = newEpisode;
      _progressPercent = newPercentage;
    });

    final isCompletedEpisode = newEpisode >= maxEpisodes;
    final isComplete = isCompletedEpisode && newPercentage >= 100.0;
    
    final finalStartDate = startDate ?? _startDate ?? progress.startDate;
    final finalEndDate = endDate ?? (isComplete ? (_endDate ?? DateTime.now()) : null);

    _progressBloc.add(
      UpdateProgressEvent(
        mediaId: widget.mediaId,
        mediaType: widget.mediaType,
        currentSeason: newSeason,
        currentEpisode: newEpisode,
        totalEpisodes: maxEpisodes,
        percentage: newPercentage,
        startDate: finalStartDate,
        endDate: finalEndDate,
        mediaTitle: widget.mediaTitle,
        mediaPoster: widget.mediaPoster,
        shouldLogActivity: shouldLogActivity, // Logger uniquement si demandé
      ),
    );
  }

  Future<void> _selectStartDate(ProgressEntity progress) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _startDate = selected);
      _applyQuickUpdate(
        progress: progress,
        startDate: selected,
      );
    }
  }

  Future<void> _selectEndDate(ProgressEntity progress) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _endDate = selected);
    }
  }
}

class _ProgressDisplay extends StatelessWidget {
  final ProgressEntity progress;

  const _ProgressDisplay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saison et Épisode
        Row(
          children: [
            Expanded(
              child: _InfoItem(
                label: 'Saison',
                value: progress.currentSeason.toString(),
                icon: Icons.theaters,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoItem(
                label: 'Épisode',
                value: '${progress.currentEpisode}/${progress.totalEpisodes}',
                icon: Icons.play_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pourcentage
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${progress.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.percentage / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
