import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talk_flutter/core/services/voice_recording_service.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/message.dart';
import 'package:talk_flutter/presentation/blocs/auth/auth_bloc.dart';
import 'package:talk_flutter/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';

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
  late final VoiceRecordingService _voiceService;
  late final int _conversationId;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceRecordingService();
    _conversationId = int.parse(widget.conversationId);

    // Initialize voice service
    _voiceService.initialize();

    // Fetch messages for this conversation
    context.read<ConversationBloc>().add(
          ConversationMessagesRequested(conversationId: _conversationId),
        );

    // Mark conversation as read
    context.read<ConversationBloc>().add(
          ConversationMarkRead(_conversationId),
        );
  }

  @override
  void dispose() {
    // Cancel any in-progress recording on screen exit
    if (_isRecording) {
      _voiceService.cancelRecording();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = context.read<AuthBloc>().state.user?.id;

    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage &&
          current.successMessage != null,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          // Navigate back after blocking user
          if (state.successMessage!.contains('차단')) {
            context.pop();
          }
        }
      },
      child: Scaffold(
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
            BlocBuilder<ConversationBloc, ConversationState>(
              buildWhen: (previous, current) =>
                  previous.conversations != current.conversations,
              builder: (context, state) {
                final conversation = state.conversations
                    .where((c) => c.id == _conversationId)
                    .firstOrNull;
                final isFavorite = conversation?.isFavorite ?? false;

                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? AppColors.warning : null,
                  ),
                  onPressed: () {
                    context.read<ConversationBloc>().add(
                          ConversationToggleFavorite(_conversationId),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite ? '즐겨찾기에서 제거됨' : '즐겨찾기에 추가됨',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
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
              child: BlocBuilder<ConversationBloc, ConversationState>(
                buildWhen: (previous, current) =>
                    previous.messages != current.messages ||
                    previous.status != current.status,
                builder: (context, state) {
                  if (state.isLoading &&
                      state.getMessages(_conversationId).isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final messages = state.getMessages(_conversationId);

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        '아직 메시지가 없습니다.\n길게 눌러서 음성 메시지를 보내보세요.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: AppSpacing.screenPadding,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;

                      return _MessageItem(
                        message: message,
                        isMe: isMe,
                      );
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
                      onLongPressStart: (_) async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isRecording = true);
                        final result = await _voiceService.startRecording();
                        if (!result.success) {
                          if (mounted) {
                            setState(() => _isRecording = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.errorMessage ?? '녹음을 시작할 수 없습니다.',
                                ),
                                action: result.isPermanentlyDenied
                                    ? SnackBarAction(
                                        label: '설정',
                                        onPressed: () =>
                                            _voiceService.openSettings(),
                                      )
                                    : null,
                              ),
                            );
                          }
                        }
                      },
                      onLongPressEnd: (_) async {
                        if (!_isRecording) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final conversationBloc =
                            context.read<ConversationBloc>();
                        setState(() => _isRecording = false);

                        final result = await _voiceService.stopRecording();
                        if (result.success &&
                            result.filePath != null &&
                            result.durationSeconds != null) {
                          if (mounted) {
                            conversationBloc.add(
                                  ConversationSendMessage(
                                    conversationId: _conversationId,
                                    audioPath: result.filePath!,
                                    duration: result.durationSeconds!,
                                  ),
                                );
                          }
                        } else if (result.errorMessage != null && mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(result.errorMessage!),
                            ),
                          );
                        }
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
                          size: _isRecording
                              ? AppIconSize.xl - 4
                              : AppIconSize.lg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('이 사용자를 차단하시겠습니까?\n차단하면 더 이상 메시지를 받을 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserBloc>().add(
                    UserBlockRequested(userId: _conversationId),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('대화 삭제'),
        content: const Text('이 대화를 삭제하시겠습니까?\n삭제된 대화는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ConversationBloc>().add(
                    ConversationDelete(_conversationId),
                  );
              context.pop();
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

/// Message item widget that renders voice messages with VoiceMessagePlayer
/// or falls back to a simple text bubble for non-voice messages.
class _MessageItem extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageItem({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final timeString = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: AppAvatarSize.sm / 2,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                message.sender?.nickname.characters.first ?? '?',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 10,
                ),
              ),
            ),
            AppSpacing.horizontalXs,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.isVoiceMessage && message.voiceUrl != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    child: VoiceMessagePlayer(
                      audioUrl: message.voiceUrl!,
                      durationSeconds: message.duration,
                      isSentByMe: isMe,
                      sourceType: 'message',
                      sourceId: message.id,
                    ),
                  )
                else
                  Container(
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
                        bottomLeft: Radius.circular(
                            isMe ? AppRadius.lg : AppRadius.xs),
                        bottomRight: Radius.circular(
                            isMe ? AppRadius.xs : AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      message.displayText,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isMe
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.horizontalXs,
          Text(
            timeString,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
