import 'package:talk_flutter/data/datasources/remote/api_client.dart';
import 'package:talk_flutter/domain/repositories/feedback_repository.dart';

/// Feedback repository implementation
/// Reuses the existing report API endpoint for feedback submission.
class FeedbackRepositoryImpl implements FeedbackRepository {
  final ApiClient _apiClient;

  FeedbackRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<void> submitFeedback({
    required String category,
    required String content,
  }) async {
    await _apiClient.createReport({
      'report': {
        'report_type': 'feedback',
        'reason': '[$category] $content',
      },
    });
  }
}
