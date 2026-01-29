# 🎯 Template pour Ajouter une Nouvelle Feature

Ce guide montre comment ajouter une nouvelle feature en suivant exactement le pattern de la feature AUTH.

## Exemple: Implémenter la Feature CATALOG

### Étape 1: Créer la Structure des Dossiers

```bash
# Domain
mkdir -p lib/features/catalog/domain/entities
mkdir -p lib/features/catalog/domain/repositories
mkdir -p lib/features/catalog/domain/usecases

# Data
mkdir -p lib/features/catalog/data/datasources
mkdir -p lib/features/catalog/data/models
mkdir -p lib/features/catalog/data/repositories

# Presentation
mkdir -p lib/features/catalog/presentation/bloc
mkdir -p lib/features/catalog/presentation/pages
mkdir -p lib/features/catalog/presentation/widgets
```

### Étape 2: Domain Layer

#### 2.1 Repository (Interface Abstraite)

**Fichier**: `lib/features/catalog/domain/repositories/catalog_repository.dart`

```dart
import '../../domain/entities/user_media.dart';

abstract class CatalogRepository {
  /// Récupérer tous les médias de l'utilisateur
  Future<List<UserMedia>> getUserMedias(String userId);

  /// Récupérer les médias par statut
  Future<List<UserMedia>> getUserMediasByStatus(
    String userId,
    String status, // 'planned', 'watching', 'completed'
  );

  /// Ajouter un média au catalogue
  Future<UserMedia> addMedia(UserMedia media);

  /// Supprimer un média du catalogue
  Future<void> removeMedia(String userMediaId);

  /// Mettre à jour un média
  Future<UserMedia> updateMedia(UserMedia media);
}
```

#### 2.2 Use Cases

**Fichier**: `lib/features/catalog/domain/usecases/catalog_usecases.dart`

```dart
import '../repositories/catalog_repository.dart';
import '../../domain/entities/user_media.dart';

/// Récupérer le catalogue de l'utilisateur
class GetUserMediasUseCase {
  final CatalogRepository repository;
  GetUserMediasUseCase(this.repository);

  Future<List<UserMedia>> call(String userId) {
    return repository.getUserMedias(userId);
  }
}

/// Récupérer par statut
class GetUserMediasByStatusUseCase {
  final CatalogRepository repository;
  GetUserMediasByStatusUseCase(this.repository);

  Future<List<UserMedia>> call(String userId, String status) {
    return repository.getUserMediasByStatus(userId, status);
  }
}

/// Ajouter un média
class AddMediaUseCase {
  final CatalogRepository repository;
  AddMediaUseCase(this.repository);

  Future<UserMedia> call(UserMedia media) {
    return repository.addMedia(media);
  }
}

/// Supprimer un média
class RemoveMediaUseCase {
  final CatalogRepository repository;
  RemoveMediaUseCase(this.repository);

  Future<void> call(String userMediaId) {
    return repository.removeMedia(userMediaId);
  }
}
```

### Étape 3: Data Layer

#### 3.1 Models

**Fichier**: `lib/features/catalog/data/models/user_media_model.dart`

```dart
import '../../domain/entities/user_media.dart';
import '../../../catalog/domain/entities/media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_media_model.g.dart';

@JsonSerializable()
class UserMediaModel {
  final String id;
  final String userId;
  final int mediaId;
  final String mediaType;
  final String status;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime dateAdded;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dateStarted;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dateCompleted;

  UserMediaModel({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.mediaType,
    required this.status,
    required this.dateAdded,
    this.dateStarted,
    this.dateCompleted,
  });

  UserMedia toEntity(Media media) {
    return UserMedia(
      id: id,
      userId: userId,
      mediaId: mediaId,
      mediaType: mediaType,
      status: status,
      media: media,
      dateAdded: dateAdded,
      dateStarted: dateStarted,
      dateCompleted: dateCompleted,
    );
  }

  factory UserMediaModel.fromJson(Map<String, dynamic> json) =>
      _$UserMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserMediaModelToJson(this);
}

DateTime? _dateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
  if (json is String) return DateTime.parse(json);
  return null;
}

dynamic _dateTimeToJson(DateTime? date) => date?.toIso8601String();
```

#### 3.2 Data Sources

**Fichier**: `lib/features/catalog/data/datasources/catalog_remote_data_source.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_media_model.dart';
import '../../domain/entities/media.dart';

abstract class CatalogRemoteDataSource {
  Future<List<UserMediaModel>> getUserMedias(String userId);
  Future<List<UserMediaModel>> getUserMediasByStatus(String userId, String status);
  Future<UserMediaModel> addMedia(UserMediaModel media);
  Future<void> removeMedia(String userMediaId);
  Future<UserMediaModel> updateMedia(UserMediaModel media);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final FirebaseFirestore _firestore;

  CatalogRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserMediaModel>> getUserMedias(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mediaLibrary')
        .get();

    return snapshot.docs
        .map((doc) => UserMediaModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<List<UserMediaModel>> getUserMediasByStatus(
    String userId,
    String status,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mediaLibrary')
        .where('status', isEqualTo: status)
        .get();

    return snapshot.docs
        .map((doc) => UserMediaModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<UserMediaModel> addMedia(UserMediaModel media) async {
    final docRef = await _firestore
        .collection('users')
        .doc(media.userId)
        .collection('mediaLibrary')
        .add(media.toJson());

    return media.copyWith(id: docRef.id);
  }

  @override
  Future<void> removeMedia(String userMediaId) async {
    // À adapter selon votre structure
  }

  @override
  Future<UserMediaModel> updateMedia(UserMediaModel media) async {
    // À adapter selon votre structure
    return media;
  }
}
```

#### 3.3 Repository Implementation

**Fichier**: `lib/features/catalog/data/repositories/catalog_repository_impl.dart`

```dart
import '../../domain/entities/user_media.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserMedia>> getUserMedias(String userId) async {
    final models = await remoteDataSource.getUserMedias(userId);
    return models.map((model) => model.toEntity(/* Media */)).toList();
  }

  @override
  Future<List<UserMedia>> getUserMediasByStatus(
    String userId,
    String status,
  ) async {
    final models = await remoteDataSource.getUserMediasByStatus(userId, status);
    return models.map((model) => model.toEntity(/* Media */)).toList();
  }

  @override
  Future<UserMedia> addMedia(UserMedia media) async {
    // À implémenter
    return media;
  }

  @override
  Future<void> removeMedia(String userMediaId) async {
    await remoteDataSource.removeMedia(userMediaId);
  }

  @override
  Future<UserMedia> updateMedia(UserMedia media) async {
    // À implémenter
    return media;
  }
}
```

### Étape 4: Presentation Layer

#### 4.1 Events & States

**Fichier**: `lib/features/catalog/presentation/bloc/catalog_event.dart`

```dart
abstract class CatalogEvent {}

class GetUserMediasEvent extends CatalogEvent {
  final String userId;
  GetUserMediasEvent(this.userId);
}

class GetMediasByStatusEvent extends CatalogEvent {
  final String userId;
  final String status;
  GetMediasByStatusEvent(this.userId, this.status);
}

class AddMediaEvent extends CatalogEvent {
  final UserMedia media;
  AddMediaEvent(this.media);
}

class RemoveMediaEvent extends CatalogEvent {
  final String userMediaId;
  RemoveMediaEvent(this.userMediaId);
}
```

**Fichier**: `lib/features/catalog/presentation/bloc/catalog_state.dart`

```dart
import '../../domain/entities/user_media.dart';

abstract class CatalogState {}

class CatalogInitialState extends CatalogState {}

class CatalogLoadingState extends CatalogState {}

class CatalogSuccessState extends CatalogState {
  final List<UserMedia> medias;
  CatalogSuccessState(this.medias);
}

class CatalogErrorState extends CatalogState {
  final String message;
  CatalogErrorState(this.message);
}
```

#### 4.2 BLoC

**Fichier**: `lib/features/catalog/presentation/bloc/catalog_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/catalog_usecases.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetUserMediasUseCase getUserMediasUseCase;
  final GetUserMediasByStatusUseCase getUserMediasByStatusUseCase;
  final AddMediaUseCase addMediaUseCase;
  final RemoveMediaUseCase removeMediaUseCase;

  CatalogBloc({
    required this.getUserMediasUseCase,
    required this.getUserMediasByStatusUseCase,
    required this.addMediaUseCase,
    required this.removeMediaUseCase,
  }) : super(CatalogInitialState()) {
    on<GetUserMediasEvent>(_onGetUserMedias);
    on<GetMediasByStatusEvent>(_onGetMediasByStatus);
    on<AddMediaEvent>(_onAddMedia);
    on<RemoveMediaEvent>(_onRemoveMedia);
  }

  Future<void> _onGetUserMedias(
    GetUserMediasEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoadingState());
    try {
      final medias = await getUserMediasUseCase(event.userId);
      emit(CatalogSuccessState(medias));
    } catch (e) {
      emit(CatalogErrorState(e.toString()));
    }
  }

  // À implémenter les autres handlers...
}
```

#### 4.3 Pages

**Fichier**: `lib/features/catalog/presentation/pages/catalog_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

class CatalogScreen extends StatefulWidget {
  final String userId;

  const CatalogScreen({required this.userId});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(GetUserMediasEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Catalogue')),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CatalogErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is CatalogSuccessState) {
            return ListView.builder(
              itemCount: state.medias.length,
              itemBuilder: (context, index) {
                final media = state.medias[index];
                return ListTile(
                  title: Text(media.media.title),
                  subtitle: Text(media.status),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
```

### Étape 5: Enregistrer dans GetIt

**Fichier**: `lib/core/di/service_locator.dart` (Ajouter à la fin)

```dart
// ===== CATALOG FEATURE =====
// Data Sources
getIt.registerSingleton<CatalogRemoteDataSource>(
  CatalogRemoteDataSourceImpl(),
);

// Repositories
getIt.registerSingleton<CatalogRepository>(
  CatalogRepositoryImpl(
    remoteDataSource: getIt<CatalogRemoteDataSource>(),
  ),
);

// Use Cases
getIt.registerSingleton<GetUserMediasUseCase>(
  GetUserMediasUseCase(getIt<CatalogRepository>()),
);
getIt.registerSingleton<GetUserMediasByStatusUseCase>(
  GetUserMediasByStatusUseCase(getIt<CatalogRepository>()),
);
getIt.registerSingleton<AddMediaUseCase>(
  AddMediaUseCase(getIt<CatalogRepository>()),
);
getIt.registerSingleton<RemoveMediaUseCase>(
  RemoveMediaUseCase(getIt<CatalogRepository>()),
);

// BLoCs
getIt.registerFactory<CatalogBloc>(
  () => CatalogBloc(
    getUserMediasUseCase: getIt<GetUserMediasUseCase>(),
    getUserMediasByStatusUseCase: getIt<GetUserMediasByStatusUseCase>(),
    addMediaUseCase: getIt<AddMediaUseCase>(),
    removeMediaUseCase: getIt<RemoveMediaUseCase>(),
  ),
);
```

### Étape 6: Ajouter les Routes

**Fichier**: `lib/core/router/app_routes.dart` (Ajouter)

```dart
// Catalog Routes
static const String catalog = '/catalog';
static const String mediaDetails = '/media/:id/:type';
```

**Fichier**: `lib/core/router/app_router.dart` (Ajouter à createRouter())

```dart
GoRoute(
  path: AppRoutes.catalog,
  name: 'catalog',
  builder: (context, state) {
    final userId = '...'; // Récupérer depuis l'auth state
    return CatalogScreen(userId: userId);
  },
),
```

---

## 📝 Checklist pour Chaque Feature

- [ ] **Domain**: Entities, Repository (abstract), Use Cases
- [ ] **Data**: Models, DataSources, Repository (impl)
- [ ] **Presentation**: Events, States, BLoC, Pages, Widgets
- [ ] **DI**: Enregistrés dans `service_locator.dart`
- [ ] **Routes**: Ajoutées dans `app_routes.dart` et `app_router.dart`
- [ ] **Compilation**: `flutter analyze` passe
- [ ] **Code generation**: `build_runner build` exécuté
- [ ] **Tests**: Tests unitaires sur les use cases (optionnel)

---

## 🚀 Résumé Rapide

1. Créer dossiers (Domain/Data/Presentation)
2. Implémenter Domain (interfaces + logique)
3. Implémenter Data (modèles + datasources)
4. Implémenter Presentation (BLoC + pages)
5. Enregistrer dans GetIt
6. Ajouter routes
7. Compiler et tester

**Bonne chance ! 🎉**
