// ========================================
// IMPORTS À AJOUTER APRÈS LES IMPORTS FEED (ligne 43)
// ========================================
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import '../../features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

// ========================================
// CONFIGURATION À AJOUTER AVANT LA DERNIÈRE ACCOLADE }
// (après la section FEED FEATURE, ligne 327)
// ========================================

  // ===== CHAT FEATURE =====
  // Data Sources
  getIt.registerSingleton<ChatRemoteDataSource>(
    ChatRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  // Repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<GetConversationsUseCase>(
    GetConversationsUseCase(getIt<ChatRepository>()),
  );
  getIt.registerSingleton<GetMessagesUseCase>(
    GetMessagesUseCase(getIt<ChatRepository>()),
  );
  getIt.registerSingleton<SendMessageUseCase>(
    SendMessageUseCase(getIt<ChatRepository>()),
  );
  getIt.registerSingleton<GetOrCreateConversationUseCase>(
    GetOrCreateConversationUseCase(getIt<ChatRepository>()),
  );
  getIt.registerSingleton<MarkMessagesAsReadUseCase>(
    MarkMessagesAsReadUseCase(getIt<ChatRepository>()),
  );

  // BLoCs
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(
      getConversationsUseCase: getIt<GetConversationsUseCase>(),
      getMessagesUseCase: getIt<GetMessagesUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      getOrCreateConversationUseCase: getIt<GetOrCreateConversationUseCase>(),
      markMessagesAsReadUseCase: getIt<MarkMessagesAsReadUseCase>(),
    ),
  );
