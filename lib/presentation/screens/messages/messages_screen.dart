import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    // Load conversations on init
    context.read<ConversationBloc>().add(const ConversationListRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          // Loading state with skeleton
          if (state.isLoading && state.conversations.isEmpty) {
            return SkeletonList.conversations(count: 6);
          }

          // Error state
          if (state.status == ConversationStatus.error && state.conversations.isEmpty) {
            return AppErrorState.generic(
              message: state.errorMessage ?? '오류가 발생했습니다',
              onRetry: () {
                context.read<ConversationBloc>().add(
                  const ConversationListRequested(refresh: true),
                );
              },
            );
          }

          // Empty state with CTA
          if (state.conversations.isEmpty) {
            return AppEmptyState.noConversations(
              onExplore: () => context.go('/'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConversationBloc>().add(
                const ConversationListRequested(refresh: true),
              );
            },
            child: ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    context.push('/messages/${conversation.id}');
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
    );
  }

  void _showDeleteConfirmation(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('대화 삭제'),
        content: Text('${conversation.partnerNickname}님과의 대화를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
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

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const _ConversationTile({
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
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false; // We handle deletion in the dialog
      },
      child: ListTile(
        onTap: onTap,
        leading: AppAvatar.withBadge(
          name: conversation.partnerNickname,
          radius: AppAvatarSize.md,
          badgeCount: conversation.hasUnreadMessages ? conversation.unreadCount : 0,
        ),
        title: Text(
          conversation.partnerNickname ?? '알 수 없음',
          style: TextStyle(
            fontWeight: conversation.hasUnreadMessages
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.mic,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                conversation.messagePreview,
                style: TextStyle(
                  color: conversation.hasUnreadMessages
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(conversation.lastMessageAt ?? conversation.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: conversation.hasUnreadMessages
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onToggleFavorite,
              child: Icon(
                conversation.isFavorite ? Icons.star : Icons.star_border,
                size: 20,
                color: conversation.isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
