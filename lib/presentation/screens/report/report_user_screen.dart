import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/user.dart';
import 'package:talk_flutter/domain/repositories/user_repository.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';

/// Report user screen - allows reporting a user for inappropriate behavior
class ReportUserScreen extends StatefulWidget {
  final String userId;

  const ReportUserScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  User? _reportedUser;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _selectedReason;
  final _detailController = TextEditingController();

  final List<String> _reportReasons = [
    '스팸 또는 광고',
    '괴롭힘 또는 따돌림',
    '혐오 발언 또는 차별',
    '불법적인 활동',
    '부적절한 콘텐츠',
    '사칭',
    '개인정보 침해',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      setState(() => _isLoading = true);

      final repository = context.read<UserRepository>();
      final user = await repository.getUserById(int.parse(widget.userId));

      setState(() {
        _reportedUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 사유를 선택해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Combine reason and details into a single report reason
      final reportReason = _detailController.text.isNotEmpty
          ? '$_selectedReason\n\n상세 내용:\n${_detailController.text}'
          : _selectedReason!;

      context.read<UserBloc>().add(
            UserReportRequested(
              userId: int.parse(widget.userId),
              reason: reportReason,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('신고 접수에 실패했습니다: $e'),
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
        title: const Text('사용자 신고'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reported user info
                    if (_reportedUser != null)
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: AppAvatarSize.sm,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  _reportedUser!.nickname.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '신고 대상',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      _reportedUser!.nickname,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: AppAvatarSize.sm,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.person),
                              ),
                              AppSpacing.horizontalMd,
                              Text(
                                '사용자 ID: ${widget.userId}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    AppSpacing.verticalXl,

                    // Report reason selection
                    Text(
                      '신고 사유',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      '해당하는 신고 사유를 선택해주세요.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    AppSpacing.verticalMd,

                    // Reason list
                    Card(
                      child: Column(
                        children: _reportReasons.map((reason) {
                          return ListTile(
                            title: Text(reason),
                            // ignore: deprecated_member_use
                            leading: Radio<String>(
                              value: reason,
                              // ignore: deprecated_member_use
                              groupValue: _selectedReason,
                              // ignore: deprecated_member_use
                              onChanged: (value) {
                                setState(() => _selectedReason = value);
                              },
                            ),
                            onTap: () {
                              setState(() => _selectedReason = reason);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    AppSpacing.verticalXl,

                    // Additional details
                    Text(
                      '상세 내용 (선택)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalXs,
                    TextFormField(
                      controller: _detailController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: '신고 내용을 자세히 설명해주세요.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    AppSpacing.verticalXl,

                    // Warning message
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: AppIconSize.md,
                            color: colorScheme.error,
                          ),
                          AppSpacing.horizontalSm,
                          Expanded(
                            child: Text(
                              '허위 신고는 제재 대상이 될 수 있습니다. 신중하게 신고해주세요.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalXl,

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        child: _isSubmitting
                            ? SizedBox(
                                width: AppIconSize.md,
                                height: AppIconSize.md,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('신고하기'),
                      ),
                    ),
                    AppSpacing.verticalMd,

                    // Block option
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showBlockConfirmation();
                        },
                        icon: const Icon(Icons.block),
                        label: const Text('이 사용자 차단하기'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text(
          '${_reportedUser?.nickname ?? '이 사용자'}를 차단하시겠습니까?\n\n차단하면 상대방의 메시지와 브로드캐스트를 받지 않습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(
                    UserBlockRequested(userId: int.parse(widget.userId)),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자를 차단했습니다.')),
              );
            },
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }
}
