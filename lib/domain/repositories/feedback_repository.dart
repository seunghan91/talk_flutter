/// Feedback repository interface - Domain layer
abstract class FeedbackRepository {
  /// Submit user feedback
  Future<void> submitFeedback({
    required String category,
    required String content,
  });
}
