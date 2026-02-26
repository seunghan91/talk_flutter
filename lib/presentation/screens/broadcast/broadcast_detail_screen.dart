import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/blocs/user/user_bloc.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';

/// Broadcast detail screen - shows a single broadcast with audio player
class BroadcastDetailScreen extends StatefulWidget {
  final String broadcastId;

  const BroadcastDetailScreen({
    super.key,
    required this.broadcastId,
  });

  @override
  State<BroadcastDetailScreen> createState() => _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends State<BroadcastDetailScreen> {
  Broadcast? _broadcast;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBroadcast();
  }

  Future<void> _loadBroadcast() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = context.read<BroadcastRepository>();
      final broadcast = await repository.getBroadcastById(int.parse(widget.broadcastId));

      if (!mounted) return;

      setState(() {
        _broadcast = broadcast;
        _isLoading = false;
      });

      // Mark as listened
      context.read<BroadcastBloc>().add(BroadcastMarkListened(broadcast.id));
    } catch (e) {
      setState(() {
        _error = '브로드캐스트를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          border: Border(
            bottom: BorderSide(color: context.borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: context.textPrimary,
                onPressed: () => context.pop(),
                tooltip: '보이스팅',
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _broadcast?.senderNickname ?? '보이스팅',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
              if (_broadcast != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: context.textSecondary),
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        context.push('/report/user/${_broadcast!.userId}');
                        break;
                      case 'block':
                        _showBlockConfirmation();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, size: AppIconSize.md),
                          AppSpacing.horizontalXs,
                          const Text('신고하기'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          const Icon(Icons.block, size: AppIconSize.md),
                          AppSpacing.horizontalXs,
                          const Text('차단하기'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppIconSize.hero,
              color: AppColors.primary,
            ),
            AppSpacing.verticalMd,
            Text(
              _error!,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 15,
              ),
            ),
            AppSpacing.verticalMd,
            _PrimaryButton(
              label: '다시 시도',
              onPressed: _loadBroadcast,
            ),
          ],
        ),
      );
    }

    final broadcast = _broadcast!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSm,

          // Sender info section
          _SenderInfoSection(broadcast: broadcast),
          AppSpacing.verticalMd,

          // Voice player card
          if (broadcast.audioUrl != null)
            _VoicePlayerCard(broadcast: broadcast),
          AppSpacing.verticalMd,

          // Action buttons grid
          _ActionButtonsGrid(
            broadcastId: widget.broadcastId,
            broadcast: broadcast,
            onReport: () => context.push('/report/user/${broadcast.userId}'),
            onBlock: _showBlockConfirmation,
          ),

          AppSpacing.verticalMd,

          // Broadcast info card
          _BroadcastInfoCard(broadcast: broadcast),

          AppSpacing.verticalXxl,
        ],
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('사용자 차단'),
        content: Text('${_broadcast?.senderNickname ?? '이 사용자'}를 차단하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: context.mutedForegroundColor),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(
                    UserBlockRequested(userId: _broadcast!.userId),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자를 차단했습니다.')),
              );
              context.pop();
            },
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }
}

// ─── Design card helper ─────────────────────────────────────────────────────

class _DesignCard extends StatelessWidget {
  final Widget child;

  const _DesignCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: child,
    );
  }
}

// ─── Sender info section ─────────────────────────────────────────────────────

class _SenderInfoSection extends StatelessWidget {
  final Broadcast broadcast;

  const _SenderInfoSection({required this.broadcast});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    final nickname = broadcast.senderNickname ?? '알 수 없음';
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';
    final genderLabel = broadcast.senderGender?.displayName ?? '';

    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    nickname,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  if (genderLabel.isNotEmpty) ...[
                    AppSpacing.horizontalXs,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        genderLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              AppSpacing.verticalXxs,
              Text(
                _timeAgo(broadcast.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: context.mutedForegroundColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Voice player card ────────────────────────────────────────────────────────

class _VoicePlayerCard extends StatelessWidget {
  final Broadcast broadcast;

  const _VoicePlayerCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return _DesignCard(
      child: Column(
        children: [
          VoiceMessagePlayer(
            audioUrl: broadcast.audioUrl!,
            durationSeconds: broadcast.duration,
            sourceType: 'broadcast',
            sourceId: broadcast.id,
          ),
          AppSpacing.verticalSm,
          // "다시듣기" button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.5),
                foregroundColor: context.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              onPressed: null, // Player handles replay internally
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '다시듣기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons grid ─────────────────────────────────────────────────────

class _ActionButtonsGrid extends StatelessWidget {
  final String broadcastId;
  final Broadcast broadcast;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const _ActionButtonsGrid({
    required this.broadcastId,
    required this.broadcast,
    required this.onReport,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 넘기기
        Expanded(
          child: _ActionButton(
            icon: Icons.skip_next_rounded,
            label: '넘기기',
            backgroundColor: context.mutedColor,
            foregroundColor: context.mutedForegroundColor,
            onPressed: () => context.pop(),
          ),
        ),
        AppSpacing.horizontalSm,
        // 신고
        Expanded(
          child: _ActionButton(
            icon: Icons.flag_outlined,
            label: '신고',
            backgroundColor: context.mutedColor,
            foregroundColor: context.mutedForegroundColor,
            onPressed: onReport,
          ),
        ),
        AppSpacing.horizontalSm,
        // 답장
        Expanded(
          child: _ActionButton(
            icon: Icons.reply_rounded,
            label: '답장',
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            foregroundColor: AppColors.primary,
            onPressed: () => context.push('/broadcast/reply/$broadcastId'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foregroundColor, size: AppIconSize.md),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Broadcast info card ─────────────────────────────────────────────────────

class _BroadcastInfoCard extends StatelessWidget {
  final Broadcast broadcast;

  const _BroadcastInfoCard({required this.broadcast});

  String _formatDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return _DesignCard(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: '보낸 시간',
            value: _formatDateTime(broadcast.createdAt),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(height: 1, color: Theme.of(context).dividerColor),
          ),
          _InfoRow(
            icon: Icons.people_outline_rounded,
            label: '수신자 수',
            value: '${broadcast.recipientCount}명',
          ),
          if (broadcast.expiredAt != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(height: 1, color: Theme.of(context).dividerColor),
            ),
            _InfoRow(
              icon: Icons.timer_off_outlined,
              label: '만료 예정',
              value: _formatDateTime(broadcast.expiredAt!),
              isWarning: broadcast.isExpiringSoon,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isWarning;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.primary : context.mutedForegroundColor;

    return Row(
      children: [
        Icon(icon, size: AppIconSize.md, color: color),
        AppSpacing.horizontalSm,
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.mutedForegroundColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: isWarning ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─── Primary button helper ────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
