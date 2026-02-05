import 'package:flutter/material.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Feedback screen for user feedback and support
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'general';
  bool _isSubmitting = false;

  final _categories = [
    {'value': 'general', 'label': '일반 문의'},
    {'value': 'bug', 'label': '버그 신고'},
    {'value': 'feature', 'label': '기능 제안'},
    {'value': 'report', 'label': '사용자 신고'},
    {'value': 'other', 'label': '기타'},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Submit feedback to API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('피드백이 전송되었습니다. 감사합니다!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        _feedbackController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('피드백 전송 실패: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: AppIconSize.xxl,
                          color: colorScheme.primary,
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          '소중한 의견을 들려주세요',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.verticalXs,
                        Text(
                          '여러분의 피드백은 Talkk를 더 좋게 만드는 데 큰 도움이 됩니다.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacing.verticalXl,

                // Category selection
                Text(
                  '카테고리',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalXs,
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category['value'],
                      child: Text(category['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),

                AppSpacing.verticalXl,

                // Feedback input
                Text(
                  '내용',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalXs,
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '여기에 내용을 입력해주세요...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    if (value.trim().length < 10) {
                      return '최소 10자 이상 입력해주세요';
                    }
                    return null;
                  },
                ),

                AppSpacing.verticalXl,

                // Submit button
                FilledButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? SizedBox(
                          height: AppIconSize.md,
                          width: AppIconSize.md,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text('피드백 보내기'),
                ),

                AppSpacing.verticalXxl,

                // FAQ section
                Text(
                  '자주 묻는 질문',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalSm,
                const _FAQItem(
                  question: '음성 메시지는 얼마나 보관되나요?',
                  answer: '브로드캐스트는 6일 후 자동으로 만료되며, 1:1 대화는 삭제하기 전까지 보관됩니다.',
                ),
                const _FAQItem(
                  question: '다른 사용자를 차단하면 어떻게 되나요?',
                  answer: '차단한 사용자로부터 브로드캐스트나 메시지를 받지 않게 됩니다.',
                ),
                const _FAQItem(
                  question: '계정을 삭제하려면 어떻게 해야 하나요?',
                  answer: '설정 > 계정 관리에서 계정 삭제를 요청할 수 있습니다.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
