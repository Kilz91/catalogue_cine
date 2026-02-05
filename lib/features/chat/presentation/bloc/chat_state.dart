part of 'chat_bloc.dart';

class ChatState {
  final List<ChatConversationEntity> conversations;
  final List<ChatMessageEntity> messages;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isSending;
  final String? errorMessage;
  final String? currentConversationId;

  const ChatState({
    this.conversations = const [],
    this.messages = const [],
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.errorMessage,
    this.currentConversationId,
  });

  ChatState copyWith({
    List<ChatConversationEntity>? conversations,
    List<ChatMessageEntity>? messages,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isSending,
    String? errorMessage,
    String? currentConversationId,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
    );
  }
}
