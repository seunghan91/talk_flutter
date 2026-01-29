import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';

// ==================== Events ====================

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class ConversationListRequested extends ConversationEvent {
  final bool refresh;

  const ConversationListRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class ConversationMessagesRequested extends ConversationEvent {
  final int conversationId;
  final bool refresh;

  const ConversationMessagesRequested({
    required this.conversationId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [conversationId, refresh];
}

class ConversationSendMessage extends ConversationEvent {
  final int conversationId;
  final String audioPath;
  final int duration;

  const ConversationSendMessage({
    required this.conversationId,
    required this.audioPath,
    required this.duration,
  });

  @override
  List<Object?> get props => [conversationId, audioPath, duration];
}

class ConversationToggleFavorite extends ConversationEvent {
  final int conversationId;

  const ConversationToggleFavorite(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ConversationDelete extends ConversationEvent {
  final int conversationId;

  const ConversationDelete(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ConversationMarkRead extends ConversationEvent {
  final int conversationId;

  const ConversationMarkRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

// ==================== State ====================

enum ConversationStatus { initial, loading, loaded, sending, error }

class ConversationState extends Equatable {
  final ConversationStatus status;
  final List<Conversation> conversations;
  final Map<int, List<Message>> messages;
  final String? errorMessage;
  final bool hasReachedMax;
  final int page;

  const ConversationState({
    this.status = ConversationStatus.initial,
    this.conversations = const [],
    this.messages = const {},
    this.errorMessage,
    this.hasReachedMax = false,
    this.page = 1,
  });

  bool get isLoading => status == ConversationStatus.loading;
  bool get isSending => status == ConversationStatus.sending;

  List<Message> getMessages(int conversationId) => messages[conversationId] ?? [];

  int get unreadCount {
    return conversations.where((c) => c.hasUnreadMessages).length;
  }

  ConversationState copyWith({
    ConversationStatus? status,
    List<Conversation>? conversations,
    Map<int, List<Message>>? messages,
    String? errorMessage,
    bool? hasReachedMax,
    int? page,
  }) {
    return ConversationState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [status, conversations, messages, errorMessage, hasReachedMax, page];
}

// ==================== BLoC ====================

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _conversationRepository;

  ConversationBloc({
    required ConversationRepository conversationRepository,
  })  : _conversationRepository = conversationRepository,
        super(const ConversationState()) {
    on<ConversationListRequested>(_onListRequested);
    on<ConversationMessagesRequested>(_onMessagesRequested);
    on<ConversationSendMessage>(_onSendMessage);
    on<ConversationToggleFavorite>(_onToggleFavorite);
    on<ConversationDelete>(_onDelete);
    on<ConversationMarkRead>(_onMarkRead);
  }

  Future<void> _onListRequested(
    ConversationListRequested event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.hasReachedMax && !event.refresh) return;

    try {
      final page = event.refresh ? 1 : state.page;
      emit(state.copyWith(status: ConversationStatus.loading));

      final conversations = await _conversationRepository.getConversations(page: page);

      emit(state.copyWith(
        status: ConversationStatus.loaded,
        conversations: event.refresh ? conversations : [...state.conversations, ...conversations],
        hasReachedMax: conversations.isEmpty,
        page: page + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMessagesRequested(
    ConversationMessagesRequested event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ConversationStatus.loading));

      final messages = await _conversationRepository.getMessages(
        conversationId: event.conversationId,
        page: 1,
      );

      final updatedMessages = Map<int, List<Message>>.from(state.messages);
      updatedMessages[event.conversationId] = messages;

      emit(state.copyWith(
        status: ConversationStatus.loaded,
        messages: updatedMessages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSendMessage(
    ConversationSendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ConversationStatus.sending));

      await _conversationRepository.sendMessage(
        conversationId: event.conversationId,
        audioPath: event.audioPath,
        duration: event.duration,
      );

      emit(state.copyWith(status: ConversationStatus.loaded));

      // Refresh messages after sending
      add(ConversationMessagesRequested(
        conversationId: event.conversationId,
        refresh: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ConversationToggleFavorite event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      // Optimistic update
      final updatedConversations = state.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(isFavorite: !c.isFavorite);
        }
        return c;
      }).toList();

      emit(state.copyWith(conversations: updatedConversations));

      // Sync with server
      await _conversationRepository.toggleFavorite(event.conversationId);
    } catch (e) {
      // Revert on error
      add(const ConversationListRequested(refresh: true));
    }
  }

  Future<void> _onDelete(
    ConversationDelete event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.deleteConversation(event.conversationId);

      final updatedConversations = state.conversations
          .where((c) => c.id != event.conversationId)
          .toList();

      emit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMarkRead(
    ConversationMarkRead event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      // Optimistic update
      final updatedConversations = state.conversations.map((c) {
        if (c.id == event.conversationId) {
          return c.copyWith(hasUnreadMessages: false, unreadCount: 0);
        }
        return c;
      }).toList();

      emit(state.copyWith(conversations: updatedConversations));

      // Sync with server
      await _conversationRepository.markAsRead(event.conversationId);
    } catch (e) {
      // Silent failure for mark as read
    }
  }
}
