import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/conversation.dart';
import 'package:talk_flutter/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:talk_flutter/presentation/widgets/common/common_widgets.dart';

/// Messages screen displaying conversations list
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(const ConversationListRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                '대화 목록',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<ConversationBloc, ConversationState>(
                builder: (context, state) {
                  // Loading state with skeleton
                  if (state.isLoading && state.conversations.isEmpty) {
                    return SkeletonList.conversations(count: 6);
                  }

                  // Error state
                  if (state.status == ConversationStatus.error &&
                      state.conversations.isEmpty) {
                    return AppErrorState.generic(
                      message: state.errorMessage ??
                          '대화 목록을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.',
                      onRetry: () {
                        context.read<ConversationBloc>().add(
                              const ConversationListRequested(refresh: true),
                            );
                      },
                    );
                  }

                  // Empty state
                  if (state.conversations.isEmpty) {
                    return _EmptyConversationsState(
                      onGoHome: () => context.go('/'),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<ConversationBloc>().add(
                            const ConversationListRequested(refresh: true),
                          );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return _ConversationCard(
                          conversation: conversation,
                          onTap: () {
                            context.push('/chats/${conversation.id}');
                          },
                          onToggleFavorite: () {
                            context.read<ConversationBloc>().add(
                                  ConversationToggleFavorite(conversation.id),
                                );
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, conversation);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('대화 삭제'),
        content: Text('${conversation.partnerNickname}님과의 대화를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ConversationBloc>().add(
                    ConversationDelete(conversation.id),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('대화가 삭제되었습니다.')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyConversationsState extends StatelessWidget {
  final VoidCallback onGoHome;

  const _EmptyConversationsState({required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.mutedColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: AppIconSize.hero,
                color: context.mutedForegroundColor,
              ),
            ),
            AppSpacing.verticalXl,
            Text(
              '아직 대화가 없어요',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.verticalSm,
            Text(
              '브로드캐스트에 답장하면 대화가 시작됩니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.mutedForegroundColor,
                  ),
            ),
            AppSpacing.verticalXl,
            TextButton(
              onPressed: onGoHome,
              style: TextButton.styleFrom(
                foregroundColor: context.mutedForegroundColor,
              ),
              child: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conversation card
// ---------------------------------------------------------------------------

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onToggleFavorite,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar with unread dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _AvatarCircle(
                      name: conversation.partnerNickname,
                      size: 56,
                    ),
                    if (conversation.hasUnreadMessages)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),

                AppSpacing.horizontalMd,

                // Name + preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conversation.partnerNickname ?? '알 수 없음',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight:
                                        conversation.hasUnreadMessages
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.partnerGender != null &&
                              conversation.partnerGender != Gender.unknown) ...[
                            AppSpacing.horizontalXs,
                            _GenderBadge(
                              gender: conversation.partnerGender!,
                            ),
                          ],
                        ],
                      ),
                      AppSpacing.verticalXxs,
                      Row(
                        children: [
                          Icon(
                            Icons.mic,
                            size: AppIconSize.xs,
                            color: context.mutedForegroundColor,
                          ),
                          AppSpacing.horizontalXxs,
                          Expanded(
                            child: Text(
                              conversation.messagePreview,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: conversation.hasUnreadMessages
                                        ? context.textPrimary
                                        : context.mutedForegroundColor,
                                    fontWeight: conversation.hasUnreadMessages
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.horizontalSm,

                // Time
                Text(
                  _formatDate(
                    conversation.lastMessageAt ?? conversation.createdAt,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: conversation.hasUnreadMessages
                            ? AppColors.primary
                            : context.mutedForegroundColor,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

/// Circle avatar with primary/20 background and first-letter initial
class _AvatarCircle extends StatelessWidget {
  final String? name;
  final double size;

  const _AvatarCircle({this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Small gender label badge
class _GenderBadge extends StatelessWidget {
  final Gender gender;

  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        gender.displayName,
        style: TextStyle(
          fontSize: 10,
          color: context.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
