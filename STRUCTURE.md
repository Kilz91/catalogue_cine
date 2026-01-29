# Structure du Projet - Catalogue Ciné

## 📁 Architecture Globale

```
lib/
├── core/                          # Couche partagée
│   ├── di/                        # Injection de dépendances (GetIt)
│   │   └── service_locator.dart
│   ├── error/                     # Gestion des erreurs
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                   # Clients HTTP
│   │   └── dio_client.dart
│   ├── router/                    # Navigation (GoRouter)
│   │   ├── app_routes.dart
│   │   └── app_router.dart
│   ├── theme/                     # Thème global
│   │   └── app_theme.dart
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   └── utils/
│       ├── exception_to_failure.dart
│       └── datetime_extension.dart
│
├── features/                      # Fonctionnalités (Feature-First)
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       └── auth_usecases.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── signup_form.dart
│   │
│   ├── catalog/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── media.dart
│   │   │   │   └── user_media.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │
│   ├── actors/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── actor.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   ├── presentation/
│   │       └── bloc/
│   │
│   ├── progress/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── progress.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── friends/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── friend.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── feed/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── activity.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── chat/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── chat_message.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── domain/
│       ├── data/
│       └── presentation/
│
├── firebase_options.dart          # Config Firebase
└── main.dart                      # Point d'entrée
```

---

## 🏛️ Clean Architecture Principles

### Domain Layer (Couche Métier)

- **Entities**: Objets immutables représentant les données métier
- **Repositories**: Interfaces abstraites définissant les contrats d'accès aux données
- **UseCases**: Logique métier encapsulée, une responsabilité par use case

**Aucune dépendance externe** (pas de Flutter, Firebase, HTTP, etc.)

### Data Layer (Couche Données)

- **Models**: Entités sérialisables (JSON/JSON serializable)
- **DataSources**: Interfaces pour Remote (API, Firebase) et Local (Cache, SharedPreferences)
- **Repositories**: Implémentation des repositories abstraits

**Dépendances**: Firebase, Dio, SharedPreferences, Hive

### Presentation Layer (Couche Présentation)

- **BLoCs/Cubits**: Gestion d'état avec flutter_bloc
- **Pages**: Écrans avec routing
- **Widgets**: Composants UI réutilisables

**Aucune logique métier** - appels via BLoCs

---

## 🧪 Patterns Utilisés

### 1. Repository Pattern

```dart
// Domain - Interface
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
}

// Data - Implémentation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({required String email, required String password})
    => remoteDataSource.login(email: email, password: password);
}
```

### 2. UseCase Pattern

```dart
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
```

### 3. BLoC Pattern

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitialState()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password
      );
      emit(AuthSuccessState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }
}
```

### 4. Dependency Injection

```dart
// Dans service_locator.dart
getIt.registerSingleton<LoginUseCase>(
  LoginUseCase(getIt<AuthRepository>()),
);

getIt.registerFactory<AuthBloc>(
  () => AuthBloc(loginUseCase: getIt<LoginUseCase>()),
);
```

---

## 📋 Stack Technique

| Couche           | Librairie          | Version |
| ---------------- | ------------------ | ------- |
| State Management | flutter_bloc       | ^8.1.5  |
| HTTP Client      | dio                | ^5.4.3  |
| Injection DI     | get_it             | ^7.7.0  |
| Navigation       | go_router          | ^14.2.7 |
| Backend          | firebase           | v2.28+  |
| Models           | freezed_annotation | ^2.4.4  |
| Serialization    | json_serializable  | ^6.9.2  |
| Local Storage    | shared_preferences | ^2.2.3  |
| Utilities        | dartz              | ^0.10.1 |

---

## 🔄 Data Flow Exemple (Authentication)

```
UI (LoginScreen)
    ↓
BLoC (AuthBloc) - Event: LoginEvent
    ↓
UseCase (LoginUseCase)
    ↓
Repository (AuthRepository)
    ↓
DataSource (AuthRemoteDataSource)
    ↓
Firebase Auth
    ↓
(Retour en sens inverse)
    ↓
State: AuthSuccessState(user)
    ↓
UI Rebuild
```

---

## 🚀 Ajouter une Nouvelle Feature

### 1. Créer la structure

```
features/my_feature/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### 2. Domain Layer

- Créer les entities (classes immuables)
- Créer l'interface du repository
- Créer les use cases

### 3. Data Layer

- Créer les modèles JSON
- Implémenter les data sources
- Implémenter le repository

### 4. Presentation Layer

- Créer les events/states du BLoC
- Créer le BLoC
- Créer les pages et widgets

### 5. Service Locator

- Enregistrer toutes les dépendances dans `service_locator.dart`

### 6. Navigation

- Ajouter les routes dans `AppRoutes`
- Ajouter les GoRoutes dans `app_router.dart`

---

## ✅ Checklist Avant de Coder

- [ ] Respecter la séparation stricte: Domain ≠ Data ≠ Presentation
- [ ] Aucune logique métier dans les widgets
- [ ] States immutables
- [ ] Repositories abstraits dans domain, implémentés dans data
- [ ] Firebase UNIQUEMENT dans le data layer
- [ ] TMDb API via services dans domain/data
- [ ] Tous les use cases dans le domain
- [ ] BLoCs/Cubits gèrent l'état, pas la logique métier
- [ ] Pas d'imports en sens inverse (domain ne dépend de rien)
