import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
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
      appBar: AppBar(
        title: const Text('브로드캐스트'),
        actions: [
          if (_broadcast != null)
            PopupMenuButton<String>(
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
                      const Icon(Icons.flag_outlined),
                      AppSpacing.horizontalXs,
                      const Text('신고하기'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      const Icon(Icons.block),
                      AppSpacing.horizontalXs,
                      const Text('차단하기'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _broadcast != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSize.hero,
              color: Theme.of(context).colorScheme.error,
            ),
            AppSpacing.verticalMd,
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            AppSpacing.verticalMd,
            FilledButton(
              onPressed: _loadBroadcast,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final broadcast = _broadcast!;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender info
          _SenderCard(broadcast: broadcast),
          AppSpacing.verticalXl,

          // Audio player
          if (broadcast.audioUrl != null)
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        AppSpacing.horizontalXs,
                        Text(
                          '음성 메시지',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalMd,
                    VoiceMessagePlayer(
                      audioUrl: broadcast.audioUrl!,
                      durationSeconds: broadcast.duration,
                    ),
                  ],
                ),
              ),
            ),
          AppSpacing.verticalMd,

          // Content
          if (broadcast.content != null && broadcast.content!.isNotEmpty)
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '메시지',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      broadcast.content!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          AppSpacing.verticalMd,

          // Broadcast info
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.access_time,
                    label: '보낸 시간',
                    value: _formatDateTime(broadcast.createdAt),
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.people,
                    label: '수신자 수',
                    value: '${broadcast.recipientCount}명',
                  ),
                  if (broadcast.expiredAt != null) ...[
                    const Divider(),
                    _InfoRow(
                      icon: Icons.timer_off,
                      label: '만료 예정',
                      value: _formatDateTime(broadcast.expiredAt!),
                      isWarning: broadcast.isExpiringSoon,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: FilledButton.icon(
          onPressed: () => context.push('/broadcast/reply/${widget.broadcastId}'),
          icon: const Icon(Icons.reply),
          label: const Text('답장하기'),
        ),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text('${_broadcast?.senderNickname ?? '이 사용자'}를 차단하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
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

  String _formatDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SenderCard extends StatelessWidget {
  final Broadcast broadcast;

  const _SenderCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            CircleAvatar(
              radius: AppAvatarSize.lg,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                broadcast.senderNickname?.substring(0, 1).toUpperCase() ?? '?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    broadcast.senderNickname ?? '알 수 없음',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    broadcast.senderGender?.displayName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final color = isWarning
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.md, color: color),
          AppSpacing.horizontalSm,
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isWarning ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }
}
