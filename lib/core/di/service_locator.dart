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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/progress/data/datasources/progress_remote_datasource.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/progress/domain/usecases/get_media_progress_usecase.dart';
import '../../features/progress/domain/usecases/update_progress_usecase.dart';
import '../../features/progress/presentation/bloc/progress_bloc.dart';
import '../../features/friends/data/datasources/friends_remote_datasource.dart';
import '../../features/friends/data/repositories/friends_repository_impl.dart';
import '../../features/friends/domain/repositories/friends_repository.dart';
import '../../features/friends/domain/usecases/friends_usecases.dart';
import '../../features/friends/presentation/bloc/friends_bloc.dart';

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
  getIt.registerSingleton<GetMediaDetailsUseCase>(
    GetMediaDetailsUseCase(getIt<CatalogRepository>()),
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

  // ===== PROGRESS FEATURE =====
  // Data Sources
  getIt.registerSingleton<ProgressRemoteDataSource>(
    ProgressRemoteDataSourceImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  );

  // Repositories
  getIt.registerSingleton<ProgressRepository>(
    ProgressRepositoryImpl(
      getIt<ProgressRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetMediaProgressUseCase>(
    GetMediaProgressUseCase(getIt<ProgressRepository>()),
  );
  getIt.registerSingleton<UpdateProgressUseCase>(
    UpdateProgressUseCase(getIt<ProgressRepository>()),
  );

  // BLoCs
  getIt.registerFactory<ProgressBloc>(
    () => ProgressBloc(
      getMediaProgressUseCase: getIt<GetMediaProgressUseCase>(),
      updateProgressUseCase: getIt<UpdateProgressUseCase>(),
    ),
  );

  // ===== FRIENDS FEATURE =====
  // Data Sources
  getIt.registerSingleton<FriendsRemoteDataSource>(
    FriendsRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  // Repositories
  getIt.registerSingleton<FriendsRepository>(
    FriendsRepositoryImpl(
      remoteDataSource: getIt<FriendsRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<SearchUsersUseCase>(
    SearchUsersUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<GetFriendsUseCase>(
    GetFriendsUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<GetReceivedFriendRequestsUseCase>(
    GetReceivedFriendRequestsUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<GetSentFriendRequestsUseCase>(
    GetSentFriendRequestsUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<SendFriendRequestUseCase>(
    SendFriendRequestUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<CancelFriendRequestUseCase>(
    CancelFriendRequestUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<AcceptFriendRequestUseCase>(
    AcceptFriendRequestUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<RejectFriendRequestUseCase>(
    RejectFriendRequestUseCase(getIt<FriendsRepository>()),
  );
  getIt.registerSingleton<RemoveFriendUseCase>(
    RemoveFriendUseCase(getIt<FriendsRepository>()),
  );

  // BLoCs
  getIt.registerFactory<FriendsBloc>(
    () => FriendsBloc(
      getFriends: getIt<GetFriendsUseCase>(),
      getReceivedRequests: getIt<GetReceivedFriendRequestsUseCase>(),
      getSentRequests: getIt<GetSentFriendRequestsUseCase>(),
      searchUsers: getIt<SearchUsersUseCase>(),
      sendFriendRequest: getIt<SendFriendRequestUseCase>(),
      cancelFriendRequest: getIt<CancelFriendRequestUseCase>(),
      acceptFriendRequest: getIt<AcceptFriendRequestUseCase>(),
      rejectFriendRequest: getIt<RejectFriendRequestUseCase>(),
      removeFriend: getIt<RemoveFriendUseCase>(),
    ),
  );
}
