import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Individual conversation screen with messages
class ConversationScreen extends StatefulWidget {
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  bool _isRecording = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: AppAvatarSize.md / 2,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                '대',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            AppSpacing.horizontalSm,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '대화 상대 ${widget.conversationId}',
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '마지막 접속: 1시간 전',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? AppColors.warning : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? '즐겨찾기에 추가됨' : '즐겨찾기에서 제거됨'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _showBlockDialog();
                  break;
                case 'report':
                  context.push('/report/user/${widget.conversationId}');
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block),
                    AppSpacing.horizontalSm,
                    const Text('차단하기'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(Icons.flag),
                    AppSpacing.horizontalSm,
                    const Text('신고하기'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete),
                    AppSpacing.horizontalSm,
                    const Text('대화 삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: AppSpacing.screenPadding,
              itemCount: 10, // TODO: Replace with actual messages
              itemBuilder: (context, index) {
                final isMe = index % 2 == 0;
                return _MessageBubble(
                  isMe: isMe,
                  time: '${10 - index}:00',
                  duration: 15 + index * 5,
                  isPlaying: false,
                  onPlay: () {
                    // TODO: Play voice message
                  },
                );
              },
            ),
          ),

          // Recording bar
          Container(
            padding: AppSpacing.screenPadding,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                      ),
                      child: Text(
                        _isRecording ? '녹음 중...' : '길게 눌러서 녹음',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  GestureDetector(
                    onLongPressStart: (_) {
                      setState(() => _isRecording = true);
                      // TODO: Start recording
                    },
                    onLongPressEnd: (_) {
                      setState(() => _isRecording = false);
                      // TODO: Stop recording and send
                    },
                    child: Container(
                      width: AppIconSize.xxl + AppSpacing.xs,
                      height: AppIconSize.xxl + AppSpacing.xs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                      child: Icon(
                        Icons.mic,
                        color: colorScheme.onPrimary,
                        size: _isRecording ? AppIconSize.xl - 4 : AppIconSize.lg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('이 사용자를 차단하시겠습니까?\n차단하면 더 이상 메시지를 받을 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Block user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자를 차단했습니다')),
              );
            },
            child: Text(
              '차단',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 삭제'),
        content: const Text('이 대화를 삭제하시겠습니까?\n삭제된 대화는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              // TODO: Delete conversation
            },
            child: Text(
              '삭제',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String time;
  final int duration;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _MessageBubble({
    required this.isMe,
    required this.time,
    required this.duration,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: AppAvatarSize.sm / 2,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                '대',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 10,
                ),
              ),
            ),
            AppSpacing.horizontalXs,
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isMe
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.xs),
                  bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.lg),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      width: AppIconSize.xl + AppSpacing.xxs,
                      height: AppIconSize.xl + AppSpacing.xxs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMe
                            ? colorScheme.onPrimary.withValues(alpha: 0.2)
                            : colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isMe ? colorScheme.onPrimary : colorScheme.primary,
                        size: AppIconSize.md,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '음성 메시지',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isMe
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.verticalXxs,
                      Text(
                        '$duration초',
                        style: textTheme.labelSmall?.copyWith(
                          color: isMe
                              ? colorScheme.onPrimary.withValues(alpha: 0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.horizontalXs,
          Text(
            time,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
