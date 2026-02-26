import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/feedback/feedback_bloc.dart';

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

    context.read<FeedbackBloc>().add(
          FeedbackSubmitted(
            category: _selectedCategory,
            content: _feedbackController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mutedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: context.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '피드백',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocListener<FeedbackBloc, FeedbackState>(
          listener: (context, state) {
            if (state.status == FeedbackStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('피드백이 전송되었습니다. 감사합니다!'),
                  backgroundColor: AppColors.success,
                ),
              );
              _feedbackController.clear();
              context.read<FeedbackBloc>().add(const FeedbackReset());
            } else if (state.status == FeedbackStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('피드백 전송 실패: ${state.errorMessage}'),
                  backgroundColor: AppColors.error,
                ),
              );
              context.read<FeedbackBloc>().add(const FeedbackReset());
            }
          },
          child: BlocBuilder<FeedbackBloc, FeedbackState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: context.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: context.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '운영진에게 의견 보내기',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '소중한 의견이 앱 개선에 큰 도움이 됩니다',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.mutedForegroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Category selection
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: context.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '카테고리',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: context.inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: context.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: context.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              dropdownColor: context.cardColor,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textPrimary,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Feedback input card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: context.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '내용',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _feedbackController,
                              builder: (context, value, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextFormField(
                                      controller: _feedbackController,
                                      maxLines: 5,
                                      maxLength: 1000,
                                      buildCounter: (context,
                                              {required currentLength,
                                              required isFocused,
                                              maxLength}) =>
                                          null,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.textPrimary,
                                        height: 1.5,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: context.inputBgColor,
                                        hintText: '불편하신 점이나 개선 아이디어를 자유롭게 작성해 주세요...',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: context.mutedForegroundColor,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: context.borderColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: context.borderColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.error),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                            AppSpacing.md),
                                      ),
                                      validator: (val) {
                                        if (val == null ||
                                            val.trim().isEmpty) {
                                          return '내용을 입력해주세요';
                                        }
                                        if (val.trim().length < 10) {
                                          return '최소 10자 이상 입력해주세요';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${value.text.length}/1000',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.mutedForegroundColor,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Submit button
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _feedbackController,
                        builder: (context, value, _) {
                          final isEmpty = value.text.trim().isEmpty;
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: (state.isSubmitting || isEmpty)
                                  ? null
                                  : _submitFeedback,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor:
                                    Theme.of(context).dividerColor,
                                foregroundColor: Colors.white,
                                disabledForegroundColor:
                                    context.textTertiary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      '보내기',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // FAQ section
                      Text(
                        '자주 묻는 질문',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      _FAQCard(
                        question: '음성 메시지는 얼마나 보관되나요?',
                        answer:
                            '브로드캐스트는 6일 후 자동으로 만료되며, 1:1 대화는 삭제하기 전까지 보관됩니다.',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _FAQCard(
                        question: '다른 사용자를 차단하면 어떻게 되나요?',
                        answer:
                            '차단한 사용자로부터 브로드캐스트나 메시지를 받지 않게 됩니다.',
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _FAQCard(
                        question: '계정을 삭제하려면 어떻게 해야 하나요?',
                        answer:
                            '설정 > 계정 관리에서 계정 삭제를 요청할 수 있습니다.',
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FAQCard extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQCard({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: context.mutedForegroundColor,
          title: Text(
            question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
