import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/domain/repositories/conversation_repository.dart';
import 'package:talk_flutter/presentation/blocs/conversation/conversation_bloc.dart';

// Mock classes
class MockConversationRepository extends Mock implements ConversationRepository {}

void main() {
  late ConversationRepository mockConversationRepository;

  setUp(() {
    mockConversationRepository = MockConversationRepository();
  });

  group('ConversationBloc', () {
    final testConversations = [
      Conversation(
        id: 1,
        partnerUserId: 2,
        partnerNickname: 'Partner 1',
        isFavorite: false,
        hasUnreadMessages: true,
        unreadCount: 3,
        createdAt: DateTime.now(),
      ),
      Conversation(
        id: 2,
        partnerUserId: 3,
        partnerNickname: 'Partner 2',
        isFavorite: true,
        hasUnreadMessages: false,
        unreadCount: 0,
        createdAt: DateTime.now(),
      ),
    ];

    final testMessages = [
      Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        content: 'Hello',
        isRead: true,
        createdAt: DateTime.now(),
      ),
      Message(
        id: 2,
        conversationId: 1,
        senderId: 2,
        voiceUrl: 'https://example.com/voice.m4a',
        duration: 10,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    ];

    group('ConversationListRequested', () {
      blocTest<ConversationBloc, ConversationState>(
        'emits [loading, loaded] when fetch succeeds',
        setUp: () {
          when(() => mockConversationRepository.getConversations(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => testConversations);
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        act: (bloc) => bloc.add(const ConversationListRequested()),
        expect: () => [
          const ConversationState(status: ConversationStatus.loading),
          ConversationState(
            status: ConversationStatus.loaded,
            conversations: testConversations,
            page: 2,
          ),
        ],
      );

      blocTest<ConversationBloc, ConversationState>(
        'emits [loading, error] when fetch fails',
        setUp: () {
          when(() => mockConversationRepository.getConversations(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenThrow(Exception('Network error'));
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        act: (bloc) => bloc.add(const ConversationListRequested()),
        expect: () => [
          const ConversationState(status: ConversationStatus.loading),
          isA<ConversationState>()
              .having((s) => s.status, 'status', ConversationStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('ConversationMessagesRequested', () {
      blocTest<ConversationBloc, ConversationState>(
        'emits [loading, loaded] with messages when fetch succeeds',
        setUp: () {
          when(() => mockConversationRepository.getMessages(
                conversationId: any(named: 'conversationId'),
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => testMessages);
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        act: (bloc) => bloc.add(const ConversationMessagesRequested(conversationId: 1)),
        expect: () => [
          const ConversationState(status: ConversationStatus.loading),
          isA<ConversationState>()
              .having((s) => s.status, 'status', ConversationStatus.loaded)
              .having((s) => s.messages[1], 'messages[1]', testMessages),
        ],
      );
    });

    group('ConversationToggleFavorite', () {
      blocTest<ConversationBloc, ConversationState>(
        'toggles favorite status optimistically',
        setUp: () {
          when(() => mockConversationRepository.toggleFavorite(any()))
              .thenAnswer((_) async {});
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        seed: () => ConversationState(
          status: ConversationStatus.loaded,
          conversations: [testConversations.first.copyWith(isFavorite: false)],
        ),
        act: (bloc) => bloc.add(const ConversationToggleFavorite(1)),
        expect: () => [
          isA<ConversationState>()
              .having(
                (s) => s.conversations.first.isFavorite,
                'isFavorite',
                true,
              ),
        ],
      );
    });

    group('ConversationMarkRead', () {
      blocTest<ConversationBloc, ConversationState>(
        'marks conversation as read optimistically',
        setUp: () {
          when(() => mockConversationRepository.markAsRead(any()))
              .thenAnswer((_) async {});
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        seed: () => ConversationState(
          status: ConversationStatus.loaded,
          conversations: [testConversations.first.copyWith(
            hasUnreadMessages: true,
            unreadCount: 5,
          )],
        ),
        act: (bloc) => bloc.add(const ConversationMarkRead(1)),
        expect: () => [
          isA<ConversationState>()
              .having(
                (s) => s.conversations.first.hasUnreadMessages,
                'hasUnreadMessages',
                false,
              )
              .having(
                (s) => s.conversations.first.unreadCount,
                'unreadCount',
                0,
              ),
        ],
      );
    });

    group('ConversationDelete', () {
      blocTest<ConversationBloc, ConversationState>(
        'removes conversation from list on success',
        setUp: () {
          when(() => mockConversationRepository.deleteConversation(any()))
              .thenAnswer((_) async {});
        },
        build: () => ConversationBloc(conversationRepository: mockConversationRepository),
        seed: () => ConversationState(
          status: ConversationStatus.loaded,
          conversations: testConversations,
        ),
        act: (bloc) => bloc.add(const ConversationDelete(1)),
        expect: () => [
          isA<ConversationState>()
              .having(
                (s) => s.conversations.length,
                'conversations.length',
                1,
              )
              .having(
                (s) => s.conversations.first.id,
                'remaining conversation id',
                2,
              ),
        ],
      );
    });

    group('unreadCount', () {
      test('calculates unread count correctly', () {
        final state = ConversationState(
          status: ConversationStatus.loaded,
          conversations: testConversations,
        );

        // First conversation has unread messages, second doesn't
        expect(state.unreadCount, equals(1));
      });
    });
  });
}
