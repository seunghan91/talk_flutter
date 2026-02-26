import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talk_flutter/domain/repositories/feedback_repository.dart';
import 'package:talk_flutter/presentation/blocs/feedback/feedback_bloc.dart';
import 'package:talk_flutter/presentation/screens/feedback/feedback_screen.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late FeedbackRepository mockRepo;

  setUp(() {
    mockRepo = MockFeedbackRepository();
  });

  Widget buildSubject() {
    final bloc = FeedbackBloc(feedbackRepository: mockRepo);
    return MaterialApp(
      home: BlocProvider<FeedbackBloc>.value(
        value: bloc,
        child: const FeedbackScreen(),
      ),
    );
  }

  group('FeedbackScreen', () {
    testWidgets('renders title and submit button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('피드백'), findsOneWidget);
      expect(find.text('피드백 보내기'), findsOneWidget);
    });

    testWidgets('shows header description', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('소중한 의견을 들려주세요'), findsOneWidget);
    });

    testWidgets('validates empty input on submit', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Scroll down to make the submit button visible
      await tester.scrollUntilVisible(
        find.text('피드백 보내기'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('피드백 보내기'));
      await tester.pumpAndSettle();

      expect(find.text('내용을 입력해주세요'), findsOneWidget);
    });

    testWidgets('validates minimum length on submit', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter short text
      await tester.enterText(find.byType(TextFormField), '짧은 글');
      await tester.pumpAndSettle();

      // Scroll to and tap submit
      await tester.scrollUntilVisible(
        find.text('피드백 보내기'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('피드백 보내기'));
      await tester.pumpAndSettle();

      expect(find.text('최소 10자 이상 입력해주세요'), findsOneWidget);
    });

    testWidgets('shows FAQ section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Scroll down to FAQ
      await tester.scrollUntilVisible(
        find.text('자주 묻는 질문'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('자주 묻는 질문'), findsOneWidget);
      expect(find.text('음성 메시지는 얼마나 보관되나요?'), findsOneWidget);
    });

    testWidgets('category dropdown shows initial selection', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('일반 문의'), findsOneWidget);
    });
  });
}
