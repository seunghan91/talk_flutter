import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/domain/repositories/feedback_repository.dart';
import 'package:talk_flutter/presentation/blocs/feedback/feedback_bloc.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late FeedbackRepository mockFeedbackRepository;

  setUp(() {
    mockFeedbackRepository = MockFeedbackRepository();
  });

  group('FeedbackBloc', () {
    group('FeedbackSubmitted', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'emits [submitting, success] when submission succeeds',
        setUp: () {
          when(() => mockFeedbackRepository.submitFeedback(
                category: any(named: 'category'),
                content: any(named: 'content'),
              )).thenAnswer((_) async {});
        },
        build: () =>
            FeedbackBloc(feedbackRepository: mockFeedbackRepository),
        act: (bloc) => bloc.add(const FeedbackSubmitted(
          category: 'bug',
          content: '앱이 갑자기 종료됩니다',
        )),
        expect: () => [
          const FeedbackState(status: FeedbackStatus.submitting),
          const FeedbackState(status: FeedbackStatus.success),
        ],
        verify: (_) {
          verify(() => mockFeedbackRepository.submitFeedback(
                category: 'bug',
                content: '앱이 갑자기 종료됩니다',
              )).called(1);
        },
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [submitting, error] when submission fails',
        setUp: () {
          when(() => mockFeedbackRepository.submitFeedback(
                category: any(named: 'category'),
                content: any(named: 'content'),
              )).thenThrow(Exception('Server error'));
        },
        build: () =>
            FeedbackBloc(feedbackRepository: mockFeedbackRepository),
        act: (bloc) => bloc.add(const FeedbackSubmitted(
          category: 'suggestion',
          content: '다크 모드 지원 부탁합니다',
        )),
        expect: () => [
          const FeedbackState(status: FeedbackStatus.submitting),
          isA<FeedbackState>()
              .having((s) => s.status, 'status', FeedbackStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'isSubmitting returns true during submission',
        setUp: () {
          when(() => mockFeedbackRepository.submitFeedback(
                category: any(named: 'category'),
                content: any(named: 'content'),
              )).thenAnswer((_) async {});
        },
        build: () =>
            FeedbackBloc(feedbackRepository: mockFeedbackRepository),
        act: (bloc) => bloc.add(const FeedbackSubmitted(
          category: 'bug',
          content: 'test',
        )),
        expect: () => [
          isA<FeedbackState>().having(
              (s) => s.isSubmitting, 'isSubmitting', true),
          isA<FeedbackState>().having(
              (s) => s.isSubmitting, 'isSubmitting', false),
        ],
      );
    });

    group('FeedbackReset', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'resets state to initial',
        build: () =>
            FeedbackBloc(feedbackRepository: mockFeedbackRepository),
        seed: () => const FeedbackState(status: FeedbackStatus.success),
        act: (bloc) => bloc.add(const FeedbackReset()),
        expect: () => [const FeedbackState()],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'clears error message on reset',
        build: () =>
            FeedbackBloc(feedbackRepository: mockFeedbackRepository),
        seed: () => const FeedbackState(
          status: FeedbackStatus.error,
          errorMessage: 'Some error',
        ),
        act: (bloc) => bloc.add(const FeedbackReset()),
        expect: () => [const FeedbackState()],
      );
    });
  });
}
