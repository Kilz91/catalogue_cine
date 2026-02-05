import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_conversation_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_or_create_conversation_usecase.dart';
import '../../domain/usecases/mark_messages_as_read_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.getOrCreateConversationUseCase,
    required this.markMessagesAsReadUseCase,
  }) : super(const ChatState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateConversationEvent>(_onCreateConversation);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoadingConversations: true, errorMessage: null));

    await emit.forEach<List<ChatConversationEntity>>(
      getConversationsUseCase.call(),
      onData: (conversations) {
        print('✅ CONVERSATIONS LOADED: ${conversations.length}');
        return state.copyWith(
          conversations: conversations,
          isLoadingConversations: false,
        );
      },
      onError: (error, stackTrace) {
        print('❌ CONVERSATIONS ERROR: $error');
        return state.copyWith(
          isLoadingConversations: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingMessages: true,
      errorMessage: null,
      currentConversationId: event.conversationId,
      messages: [],
    ));

    await emit.forEach<List<ChatMessageEntity>>(
      getMessagesUseCase.call(event.conversationId),
      onData: (messages) {
        print('✅ MESSAGES LOADED: ${messages.length}');
        return state.copyWith(
          messages: messages,
          isLoadingMessages: false,
        );
      },
      onError: (error, stackTrace) {
        print('❌ MESSAGES ERROR: $error');
        return state.copyWith(
          isLoadingMessages: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.content.trim().isEmpty) return;

    emit(state.copyWith(isSending: true));

    try {
      await sendMessageUseCase.call(
        conversationId: event.conversationId,
        content: event.content,
      );
      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      ));
      print('❌ SEND MESSAGE ERROR: $e');
    }
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversationId =
          await getOrCreateConversationUseCase.call(event.friendId);
      print('✅ CONVERSATION ID: $conversationId');
      // La navigation sera gérée dans l'UI
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      print('❌ CREATE CONVERSATION ERROR: $e');
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await markMessagesAsReadUseCase.call(event.conversationId);
    } catch (e) {
      print('❌ MARK AS READ ERROR: $e');
    }
  }
}
