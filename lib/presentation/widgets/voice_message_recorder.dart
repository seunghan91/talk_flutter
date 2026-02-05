import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:talk_flutter/core/services/voice_recording_service.dart';
import 'package:talk_flutter/core/theme/theme.dart';

/// Inline voice message recorder widget for conversations
/// Provides a compact recording interface with waveform visualization
class VoiceMessageRecorder extends StatefulWidget {
  final Function(String audioPath, int durationSeconds)? onRecordingComplete;
  final VoidCallback? onRecordingCancelled;
  final int maxDurationSeconds;

  const VoiceMessageRecorder({
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
    this.maxDurationSeconds = 60,
  });

  @override
  State<VoiceMessageRecorder> createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder> {
  final VoiceRecordingService _recordingService = VoiceRecordingService();

  Timer? _durationTimer;
  RecorderState _state = RecorderState.idle;
  Duration _recordingDuration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recordingService.initialize();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _recordingService.reset();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _state = RecorderState.starting;
      _errorMessage = null;
    });

    final result = await _recordingService.startRecording();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _state = RecorderState.recording;
        _recordingDuration = Duration.zero;
      });
      _startDurationTimer();
    } else {
      setState(() {
        _state = RecorderState.error;
        _errorMessage = result.errorMessage;
      });

      if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });

      if (_recordingDuration.inSeconds >= widget.maxDurationSeconds) {
        _stopAndSend();
      }
    });
  }

  Future<void> _stopAndSend() async {
    _durationTimer?.cancel();

    setState(() {
      _state = RecorderState.stopping;
    });

    final result = await _recordingService.stopRecording();

    if (!mounted) return;

    if (result.success && result.filePath != null) {
      final duration = result.durationSeconds ?? _recordingDuration.inSeconds;
      widget.onRecordingComplete?.call(result.filePath!, duration);

      setState(() {
        _state = RecorderState.idle;
        _recordingDuration = Duration.zero;
      });
    } else {
      setState(() {
        _state = RecorderState.error;
        _errorMessage = result.errorMessage;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _durationTimer?.cancel();
    await _recordingService.cancelRecording();

    if (!mounted) return;

    setState(() {
      _state = RecorderState.idle;
      _recordingDuration = Duration.zero;
    });

    widget.onRecordingCancelled?.call();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마이크 권한 필요'),
        content: const Text(
          '음성 메시지를 보내려면 마이크 권한이 필요합니다.\n설정에서 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _recordingService.openSettings();
            },
            child: const Text('설정'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Error state
    if (_state == RecorderState.error) {
      return Semantics(
        label: '녹음 오류',
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                semanticLabel: '오류 아이콘',
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  _errorMessage ?? '녹음에 실패했습니다',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              Tooltip(
                message: '닫기',
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _state = RecorderState.idle;
                      _errorMessage = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Idle state - show record button
    if (_state == RecorderState.idle) {
      return Semantics(
        label: '음성 메시지 녹음 시작',
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.extraLargeRadius,
                  ),
                  child: Text(
                    '음성 메시지 녹음...',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              AppSpacing.horizontalXs,
              Tooltip(
                message: '녹음 시작',
                child: FloatingActionButton.small(
                  onPressed: _startRecording,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.mic),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Recording state
    return Semantics(
      label: '녹음 중',
      hint: '삭제하려면 왼쪽 버튼, 전송하려면 오른쪽 버튼을 탭하세요',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Waveform visualization
            if (_state == RecorderState.recording &&
                _recordingService.recorderController != null)
              SizedBox(
                height: 48,
                child: AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width - 48, 48),
                  recorderController: _recordingService.recorderController!,
                  waveStyle: WaveStyle(
                    waveColor: colorScheme.error,
                    extendWaveform: true,
                    showMiddleLine: false,
                    spacing: 6.0,
                    waveThickness: 3.0,
                    showDurationLabel: false,
                  ),
                  enableGesture: false,
                ),
              )
            else
              const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),

            AppSpacing.verticalXs,

            // Controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                Tooltip(
                  message: '녹음 취소',
                  child: IconButton(
                    onPressed: _state == RecorderState.recording ? _cancelRecording : null,
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                  ),
                ),

                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _state == RecorderState.recording
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      AppSpacing.horizontalXs,
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),

                // Send button
                Tooltip(
                  message: '전송',
                  child: IconButton.filled(
                    onPressed: _state == RecorderState.recording &&
                            _recordingDuration.inSeconds > 0
                        ? _stopAndSend
                        : null,
                    icon: _state == RecorderState.stopping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ],
            ),

            // Progress bar
            AppSpacing.verticalXs,
            LinearProgressIndicator(
              value: _recordingDuration.inSeconds / widget.maxDurationSeconds,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

/// Recorder state
enum RecorderState {
  idle,
  starting,
  recording,
  stopping,
  error,
}
