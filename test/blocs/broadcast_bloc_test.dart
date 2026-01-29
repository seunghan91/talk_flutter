import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';

// Mock classes
class MockBroadcastRepository extends Mock implements BroadcastRepository {}

void main() {
  late BroadcastRepository mockBroadcastRepository;

  setUp(() {
    mockBroadcastRepository = MockBroadcastRepository();
  });

  group('BroadcastBloc', () {
    final testBroadcasts = [
      Broadcast(
        id: 1,
        userId: 1,
        content: 'Test broadcast 1',
        audioUrl: 'https://example.com/audio1.m4a',
        duration: 30,
        recipientCount: 10,
        replyCount: 2,
        createdAt: DateTime.now(),
      ),
      Broadcast(
        id: 2,
        userId: 2,
        content: 'Test broadcast 2',
        audioUrl: 'https://example.com/audio2.m4a',
        duration: 45,
        recipientCount: 15,
        replyCount: 5,
        createdAt: DateTime.now(),
      ),
    ];

    group('BroadcastListRequested', () {
      blocTest<BroadcastBloc, BroadcastState>(
        'emits [loading, loaded] when fetch succeeds',
        setUp: () {
          when(() => mockBroadcastRepository.getBroadcasts(page: any(named: 'page')))
              .thenAnswer((_) async => testBroadcasts);
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        act: (bloc) => bloc.add(const BroadcastListRequested()),
        expect: () => [
          const BroadcastState(status: BroadcastStatus.loading),
          BroadcastState(
            status: BroadcastStatus.loaded,
            broadcasts: testBroadcasts,
            page: 2,
          ),
        ],
        verify: (_) {
          verify(() => mockBroadcastRepository.getBroadcasts(page: 1)).called(1);
        },
      );

      blocTest<BroadcastBloc, BroadcastState>(
        'emits [loading, error] when fetch fails',
        setUp: () {
          when(() => mockBroadcastRepository.getBroadcasts(page: any(named: 'page')))
              .thenThrow(Exception('Network error'));
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        act: (bloc) => bloc.add(const BroadcastListRequested()),
        expect: () => [
          const BroadcastState(status: BroadcastStatus.loading),
          isA<BroadcastState>()
              .having((s) => s.status, 'status', BroadcastStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );

      blocTest<BroadcastBloc, BroadcastState>(
        'refresh replaces existing broadcasts',
        setUp: () {
          when(() => mockBroadcastRepository.getBroadcasts(page: any(named: 'page')))
              .thenAnswer((_) async => testBroadcasts);
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        seed: () => BroadcastState(
          status: BroadcastStatus.loaded,
          broadcasts: [testBroadcasts.first],
          page: 2,
        ),
        act: (bloc) => bloc.add(const BroadcastListRequested(refresh: true)),
        expect: () => [
          isA<BroadcastState>().having((s) => s.status, 'status', BroadcastStatus.loading),
          isA<BroadcastState>()
              .having((s) => s.broadcasts.length, 'broadcasts.length', 2)
              .having((s) => s.page, 'page', 2),
        ],
      );

      blocTest<BroadcastBloc, BroadcastState>(
        'does not fetch when hasReachedMax is true and not refreshing',
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        seed: () => const BroadcastState(
          status: BroadcastStatus.loaded,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const BroadcastListRequested()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockBroadcastRepository.getBroadcasts(page: any(named: 'page')));
        },
      );
    });

    group('BroadcastMarkListened', () {
      blocTest<BroadcastBloc, BroadcastState>(
        'marks broadcast as listened optimistically',
        setUp: () {
          when(() => mockBroadcastRepository.markAsListened(any()))
              .thenAnswer((_) async {});
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        seed: () => BroadcastState(
          status: BroadcastStatus.loaded,
          broadcasts: [testBroadcasts.first.copyWith(isListened: false)],
        ),
        act: (bloc) => bloc.add(const BroadcastMarkListened(1)),
        expect: () => [
          isA<BroadcastState>()
              .having(
                (s) => s.broadcasts.first.isListened,
                'isListened',
                true,
              ),
        ],
      );
    });

    group('BroadcastCreateRequested', () {
      blocTest<BroadcastBloc, BroadcastState>(
        'emits [creating, loaded] and refreshes list on success',
        setUp: () {
          when(() => mockBroadcastRepository.createBroadcast(
                audioPath: any(named: 'audioPath'),
                duration: any(named: 'duration'),
                recipientCount: any(named: 'recipientCount'),
              )).thenAnswer((_) async => testBroadcasts.first);
          when(() => mockBroadcastRepository.getBroadcasts(page: any(named: 'page')))
              .thenAnswer((_) async => testBroadcasts);
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        act: (bloc) => bloc.add(const BroadcastCreateRequested(
          audioPath: '/path/to/audio.m4a',
          duration: 30,
          recipientCount: 5,
        )),
        expect: () => [
          const BroadcastState(status: BroadcastStatus.creating),
          const BroadcastState(status: BroadcastStatus.loaded),
          // List refresh will add loading state
          isA<BroadcastState>().having((s) => s.status, 'status', BroadcastStatus.loading),
          isA<BroadcastState>().having((s) => s.status, 'status', BroadcastStatus.loaded),
        ],
      );
    });

    group('BroadcastReplyRequested', () {
      blocTest<BroadcastBloc, BroadcastState>(
        'emits [creating, loaded] on success',
        setUp: () {
          when(() => mockBroadcastRepository.replyToBroadcast(
                broadcastId: any(named: 'broadcastId'),
                audioPath: any(named: 'audioPath'),
                duration: any(named: 'duration'),
              )).thenAnswer((_) async {});
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        act: (bloc) => bloc.add(const BroadcastReplyRequested(
          broadcastId: 1,
          audioPath: '/path/to/audio.m4a',
          duration: 15,
        )),
        expect: () => [
          const BroadcastState(status: BroadcastStatus.creating),
          const BroadcastState(status: BroadcastStatus.loaded),
        ],
      );

      blocTest<BroadcastBloc, BroadcastState>(
        'emits [creating, error] on failure',
        setUp: () {
          when(() => mockBroadcastRepository.replyToBroadcast(
                broadcastId: any(named: 'broadcastId'),
                audioPath: any(named: 'audioPath'),
                duration: any(named: 'duration'),
              )).thenThrow(Exception('Failed to reply'));
        },
        build: () => BroadcastBloc(broadcastRepository: mockBroadcastRepository),
        act: (bloc) => bloc.add(const BroadcastReplyRequested(
          broadcastId: 1,
          audioPath: '/path/to/audio.m4a',
          duration: 15,
        )),
        expect: () => [
          const BroadcastState(status: BroadcastStatus.creating),
          isA<BroadcastState>()
              .having((s) => s.status, 'status', BroadcastStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });
  });
}
