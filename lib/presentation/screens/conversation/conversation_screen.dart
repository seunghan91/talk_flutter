import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talk_flutter/core/enums/app_enums.dart';
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

    _voiceService.initialize();

    context.read<ConversationBloc>().add(
          ConversationMessagesRequested(conversationId: _conversationId),
        );

    context.read<ConversationBloc>().add(
          ConversationMarkRead(_conversationId),
        );
  }

  @override
  void dispose() {
    if (_isRecording) {
      _voiceService.cancelRecording();
    }
    super.dispose();
  }

  // Resolve partner info from ConversationBloc state
  (String nickname, Gender? gender) _partnerInfo(ConversationState state) {
    final conversation = state.conversations
        .where((c) => c.id == _conversationId)
        .firstOrNull;
    return (
      conversation?.partnerNickname ?? '대화 상대',
      conversation?.partnerGender,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (state.successMessage!.contains('차단')) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.mutedColor,
        appBar: _ConversationAppBar(
          conversationId: _conversationId,
          onReport: () => context.push('/report/user/${widget.conversationId}'),
          onLeave: () => _showDeleteDialog(),
          partnerInfoBuilder: (state) => _partnerInfo(state),
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
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final messages = state.getMessages(_conversationId);

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic_none_rounded,
                              size: AppIconSize.xl,
                              color: AppColors.primary,
                            ),
                          ),
                          AppSpacing.verticalMd,
                          Text(
                            '아직 메시지가 없습니다',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: context.textPrimary),
                          ),
                          AppSpacing.verticalXs,
                          Text(
                            '길게 눌러서 음성 메시지를 보내보세요.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.mutedForegroundColor),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;
                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),

            // Recording input bar
            _RecordingBar(
              isRecording: _isRecording,
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
                                onPressed: () => _voiceService.openSettings(),
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
                final conversationBloc = context.read<ConversationBloc>();
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
                    SnackBar(content: Text(result.errorMessage!)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('대화 삭제'),
        content: const Text(
          '이 대화를 삭제하시겠습니까?\n삭제된 대화는 복구할 수 없습니다.',
        ),
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
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom AppBar
// ---------------------------------------------------------------------------

class _ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int conversationId;
  final VoidCallback onReport;
  final VoidCallback onLeave;
  final (String, Gender?) Function(ConversationState) partnerInfoBuilder;

  const _ConversationAppBar({
    required this.conversationId,
    required this.onReport,
    required this.onLeave,
    required this.partnerInfoBuilder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      buildWhen: (previous, current) =>
          previous.conversations != current.conversations,
      builder: (context, state) {
        final (nickname, gender) = partnerInfoBuilder(state);

        return AppBar(
          backgroundColor: context.cardColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          // Surface background with bottom border
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                bottom: BorderSide(color: context.borderColor),
              ),
            ),
          ),

          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: context.textPrimary,
              ),
              onPressed: () => context.pop(),
            ),
          ),

          title: Row(
            children: [
              // Avatar 40x40
              _HeaderAvatar(name: nickname, size: 40),
              AppSpacing.horizontalSm,

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nickname,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (gender != null && gender != Gender.unknown) ...[
                          AppSpacing.horizontalXs,
                          _SmallGenderBadge(gender: gender),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            // Report
            IconButton(
              icon: Icon(
                Icons.flag_outlined,
                size: AppIconSize.md,
                color: context.mutedForegroundColor,
              ),
              onPressed: onReport,
              tooltip: '신고하기',
            ),
            // Leave / delete
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                size: AppIconSize.md,
                color: AppColors.error,
              ),
              onPressed: onLeave,
              tooltip: '대화 나가기',
            ),
            AppSpacing.horizontalXxs,
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender nickname above received bubble
          if (!isMe && message.sender?.nickname != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.sender!.nickname,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.mutedForegroundColor,
                ),
              ),
            ),

          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Voice player or text bubble
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  child: message.isVoiceMessage && message.voiceUrl != null
                      ? _VoiceBubble(
                          message: message,
                          isMe: isMe,
                          timeString: timeString,
                        )
                      : _TextBubble(
                          message: message,
                          isMe: isMe,
                          timeString: timeString,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Voice bubble
// ---------------------------------------------------------------------------

class _VoiceBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String timeString;

  const _VoiceBubble({
    required this.message,
    required this.isMe,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleBg =
        isMe ? AppColors.primary : context.cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.xs),
          bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.lg),
        ),
        border: isMe
            ? null
            : Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Play button + waveform row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Styled play circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                ),
                child: VoiceMessagePlayer(
                  audioUrl: message.voiceUrl!,
                  durationSeconds: message.duration,
                  isSentByMe: isMe,
                  sourceType: 'message',
                  sourceId: message.id,
                ),
              ),
            ],
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : context.mutedForegroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text bubble (fallback for non-voice messages)
// ---------------------------------------------------------------------------

class _TextBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String timeString;

  const _TextBubble({
    required this.message,
    required this.isMe,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : context.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.xs),
          bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.lg),
        ),
        border: isMe ? null : Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.displayText,
            style: TextStyle(
              color: isMe ? Colors.white : context.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 10,
              color: isMe
                  ? Colors.white.withValues(alpha: 0.7)
                  : context.mutedForegroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recording bar
// ---------------------------------------------------------------------------

class _RecordingBar extends StatelessWidget {
  final bool isRecording;
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressEndDetails) onLongPressEnd;

  const _RecordingBar({
    required this.isRecording,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.borderColor)),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Hint pill
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isRecording
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : context.inputBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isRecording
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : context.borderColor,
                  ),
                ),
                child: Text(
                  isRecording ? '녹음 중...' : '길게 눌러서 녹음',
                  style: TextStyle(
                    color: isRecording
                        ? AppColors.primary
                        : context.mutedForegroundColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            AppSpacing.horizontalSm,

            // Mic button
            GestureDetector(
              onLongPressStart: onLongPressStart,
              onLongPressEnd: onLongPressEnd,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? AppColors.error : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: isRecording ? AppIconSize.lg - 2 : AppIconSize.lg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header avatar (40x40)
// ---------------------------------------------------------------------------

class _HeaderAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _HeaderAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

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

// ---------------------------------------------------------------------------
// Small gender badge (for AppBar)
// ---------------------------------------------------------------------------

class _SmallGenderBadge extends StatelessWidget {
  final Gender gender;

  const _SmallGenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        gender.displayName,
        style: TextStyle(
          fontSize: 9,
          color: context.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
