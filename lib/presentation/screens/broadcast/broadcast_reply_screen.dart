import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/domain/entities/broadcast.dart';
import 'package:talk_flutter/domain/repositories/broadcast_repository.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_player.dart';
import 'package:talk_flutter/presentation/widgets/voice_message_recorder.dart';

/// Broadcast reply screen - record and send a reply to a broadcast
class BroadcastReplyScreen extends StatefulWidget {
  final String broadcastId;

  const BroadcastReplyScreen({
    super.key,
    required this.broadcastId,
  });

  @override
  State<BroadcastReplyScreen> createState() => _BroadcastReplyScreenState();
}

class _BroadcastReplyScreenState extends State<BroadcastReplyScreen> {
  Broadcast? _broadcast;
  bool _isLoading = true;
  String? _error;
  String? _recordedPath;
  int _recordedDuration = 0;
  bool _isSending = false;

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

      setState(() {
        _broadcast = broadcast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '브로드캐스트를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendReply() async {
    if (_recordedPath == null) return;

    setState(() => _isSending = true);

    try {
      context.read<BroadcastBloc>().add(
            BroadcastReplyRequested(
              broadcastId: int.parse(widget.broadcastId),
              audioPath: _recordedPath!,
              duration: _recordedDuration,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답장을 보냈습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답장 전송에 실패했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('답장하기'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
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
            Text(_error!),
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
          // Original broadcast info
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          broadcast.senderNickname?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${broadcast.senderNickname ?? '알 수 없음'}님의 브로드캐스트',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _formatDate(broadcast.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (broadcast.audioUrl != null) ...[
                    AppSpacing.verticalMd,
                    VoiceMessagePlayer(
                      audioUrl: broadcast.audioUrl!,
                      durationSeconds: broadcast.duration,
                    ),
                  ],
                  if (broadcast.content != null && broadcast.content!.isNotEmpty) ...[
                    AppSpacing.verticalSm,
                    Text(
                      broadcast.content!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppSpacing.verticalXl,

          // Reply section
          Text(
            '음성 답장 녹음',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.verticalXs,
          Text(
            '아래 버튼을 눌러 음성 메시지를 녹음하세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          AppSpacing.verticalXl,

          // Voice recorder
          Card(
            child: Padding(
              padding: AppSpacing.dialogPadding,
              child: VoiceMessageRecorder(
                onRecordingComplete: (path, duration) {
                  setState(() {
                    _recordedPath = path;
                    _recordedDuration = duration;
                  });
                },
              ),
            ),
          ),

          // Send button
          if (_recordedPath != null) ...[
            AppSpacing.verticalXl,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSending ? null : _sendReply,
                icon: _isSending
                    ? SizedBox(
                        width: AppIconSize.md,
                        height: AppIconSize.md,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSending ? '전송 중...' : '답장 보내기'),
              ),
            ),
          ],

          AppSpacing.verticalXxl,

          // Info
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppIconSize.md,
                  color: Theme.of(context).colorScheme.primary,
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    '답장을 보내면 상대방과 1:1 대화가 시작됩니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
