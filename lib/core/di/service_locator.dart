import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/datasources/tmdb_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/catalog_usecases.dart';
import '../../features/catalog/presentation/bloc/catalog_bloc.dart';
import '../../features/actors/data/datasources/tmdb_actor_data_source.dart';
import '../../features/actors/data/repositories/actor_repository_impl.dart';
import '../../features/actors/domain/repositories/actor_repository.dart';
import '../../features/actors/domain/usecases/actor_usecases.dart';
import '../../features/actors/presentation/bloc/actor_bloc.dart';

/// Service locator pour l'injection de dépendances
final getIt = GetIt.instance;

/// Initialiser tous les dépendances
Future<void> setupServiceLocator() async {
  // ===== CORE =====
  getIt.registerSingleton<DioClient>(DioClient());

  // ===== AUTH FEATURE =====
  // Data Sources
  getIt.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<SignUpUseCase>(
    SignUpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<IsUserLoggedInUseCase>(
    IsUserLoggedInUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ResetPasswordUseCase>(
    ResetPasswordUseCase(getIt<AuthRepository>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signUpUseCase: getIt<SignUpUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      isUserLoggedInUseCase: getIt<IsUserLoggedInUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );

  // ===== PROFILE FEATURE =====
  // Data Sources
  getIt.registerSingleton<ProfileRemoteDataSource>(
    ProfileRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(remoteDataSource: getIt<ProfileRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<GetUserProfileUseCase>(
    GetUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerSingleton<UpdateUserProfileUseCase>(
    UpdateUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerSingleton<UploadProfileImageUseCase>(
    UploadProfileImageUseCase(getIt<ProfileRepository>()),
  );

  // Cubits
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
      updateUserProfileUseCase: getIt<UpdateUserProfileUseCase>(),
      uploadProfileImageUseCase: getIt<UploadProfileImageUseCase>(),
    ),
  );

  // ===== CATALOG FEATURE =====
  // Data Sources
  getIt.registerSingleton<TmdbRemoteDataSource>(
    TmdbRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerSingleton<CatalogRemoteDataSource>(
    CatalogRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<CatalogRepository>(
    CatalogRepositoryImpl(
      catalogRemoteDataSource: getIt<CatalogRemoteDataSource>(),
      tmdbRemoteDataSource: getIt<TmdbRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<SearchMediaUseCase>(
    SearchMediaUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerSingleton<GetUserCatalogUseCase>(
    GetUserCatalogUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerSingleton<AddToCatalogUseCase>(
    AddToCatalogUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerSingleton<UpdateCatalogStatusUseCase>(
    UpdateCatalogStatusUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerSingleton<RemoveFromCatalogUseCase>(
    RemoveFromCatalogUseCase(getIt<CatalogRepository>()),
  );

  // BLoCs
  getIt.registerFactory<CatalogBloc>(
    () => CatalogBloc(
      searchMediaUseCase: getIt<SearchMediaUseCase>(),
      getUserCatalogUseCase: getIt<GetUserCatalogUseCase>(),
      addToCatalogUseCase: getIt<AddToCatalogUseCase>(),
      updateCatalogStatusUseCase: getIt<UpdateCatalogStatusUseCase>(),
      removeFromCatalogUseCase: getIt<RemoveFromCatalogUseCase>(),
    ),
  );

  // ===== ACTORS FEATURE =====
  // Data Sources
  getIt.registerSingleton<TmdbActorDataSource>(
    TmdbActorDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<ActorRepository>(
    ActorRepositoryImpl(tmdbDataSource: getIt<TmdbActorDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<GetActorDetailsUseCase>(
    GetActorDetailsUseCase(getIt<ActorRepository>()),
  );
  getIt.registerSingleton<GetActorCreditsUseCase>(
    GetActorCreditsUseCase(getIt<ActorRepository>()),
  );
  getIt.registerSingleton<GetMediaCastUseCase>(
    GetMediaCastUseCase(getIt<ActorRepository>()),
  );

  // BLoCs
  getIt.registerFactory<ActorBloc>(
    () => ActorBloc(
      getActorDetailsUseCase: getIt<GetActorDetailsUseCase>(),
      getActorCreditsUseCase: getIt<GetActorCreditsUseCase>(),
      getMediaCastUseCase: getIt<GetMediaCastUseCase>(),
    ),
  );
}
