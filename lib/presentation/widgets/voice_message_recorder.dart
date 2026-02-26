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

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder>
    with SingleTickerProviderStateMixin {
  final VoiceRecordingService _recordingService = VoiceRecordingService();

  Timer? _durationTimer;
  RecorderState _state = RecorderState.idle;
  Duration _recordingDuration = Duration.zero;
  String? _errorMessage;

  // Pulse animation for recording state
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeRecorder() async {
    await _recordingService.initialize();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
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
      final duration =
          result.durationSeconds ?? _recordingDuration.inSeconds;
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
    // Error state
    if (_state == RecorderState.error) {
      return Semantics(
        label: '녹음 오류',
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                semanticLabel: '오류 아이콘',
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  _errorMessage ?? '녹음에 실패했습니다',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              Tooltip(
                message: '닫기',
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mutedForeground),
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

    // Idle state - centered mic button
    if (_state == RecorderState.idle) {
      return _buildIdleState();
    }

    // Recording / stopping / has-recording state
    return _buildActiveRecorderState();
  }

  // -------------------------------------------------------------------------
  // Idle - centered 80px mic button
  // -------------------------------------------------------------------------
  Widget _buildIdleState() {
    return Semantics(
      label: '음성 메시지 녹음 시작',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              '음성 메시지 녹음',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D1B1B),
                  ),
            ),
            AppSpacing.verticalXs,
            Text(
              '버튼을 눌러 녹음을 시작하세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
            AppSpacing.verticalLg,

            // 80px mic button - idle style
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.muted,
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.mutedForeground,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Active recorder (recording / stopping)
  // -------------------------------------------------------------------------
  Widget _buildActiveRecorderState() {
    final isRecording = _state == RecorderState.recording;
    final isStopping = _state == RecorderState.stopping;

    return Semantics(
      label: '녹음 중',
      hint: '취소하려면 X 버튼, 전송하려면 전송 버튼을 탭하세요',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + subtitle
            Text(
              '음성 메시지 녹음',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D1B1B),
                  ),
            ),
            AppSpacing.verticalXs,
            Text(
              isRecording ? '녹음 중...' : '처리 중...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
            AppSpacing.verticalLg,

            // 80px mic button - animated while recording
            _buildRecordingMicButton(isRecording),
            AppSpacing.verticalMd,

            // Duration (large monospace, primary color when recording)
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isRecording ? AppColors.primary : AppColors.mutedForeground,
                letterSpacing: 2,
              ),
            ),
            AppSpacing.verticalMd,

            // Waveform
            if (isRecording && _recordingService.recorderController != null)
              SizedBox(
                height: 48,
                child: AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width - 64, 48),
                  recorderController: _recordingService.recorderController!,
                  waveStyle: const WaveStyle(
                    waveColor: AppColors.primary,
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
              SizedBox(
                height: 48,
                child: Center(
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    color: AppColors.primary,
                  ),
                ),
              ),

            AppSpacing.verticalMd,

            // Progress bar (time remaining)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: _recordingDuration.inSeconds / widget.maxDurationSeconds,
                minHeight: 3,
                backgroundColor: AppColors.neutral200,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.verticalLg,

            // Control buttons
            _buildControlButtons(isRecording, isStopping),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingMicButton(bool isRecording) {
    final Color bgColor = isRecording ? AppColors.primary : AppColors.secondary;
    final Color iconColor = isRecording ? Colors.white : AppColors.primary;

    if (isRecording) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.mic_rounded,
            color: iconColor,
            size: 36,
          ),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor.withValues(alpha: 0.5),
      ),
      child: Icon(
        Icons.mic_rounded,
        color: iconColor,
        size: 36,
      ),
    );
  }

  Widget _buildControlButtons(bool isRecording, bool isStopping) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stop recording button (full width, destructive)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isRecording ? _stopRecordingOnly : null,
            icon: const Icon(Icons.stop_rounded, size: 20),
            label: const Text(
              '녹음 중지',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              elevation: 0,
            ),
          ),
        ),
        AppSpacing.verticalSm,

        // Secondary row: New recording + Send
        Row(
          children: [
            // New recording button
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: isRecording ? null : _resetRecording,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    '다시 녹음',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.mutedForeground,
                    disabledBackgroundColor:
                        AppColors.muted.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.horizontalSm,

            // Send button
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: (isRecording && _recordingDuration.inSeconds > 0)
                      ? _stopAndSend
                      : null,
                  icon: isStopping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    '보내기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalXs,

        // Cancel ghost button
        TextButton.icon(
          onPressed: isRecording ? _cancelRecording : null,
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('취소'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  /// Stop recorder without sending (for "다시 녹음" prep)
  Future<void> _stopRecordingOnly() async {
    _durationTimer?.cancel();
    await _recordingService.stopRecording();

    if (!mounted) return;
    setState(() {
      _state = RecorderState.idle;
      _recordingDuration = Duration.zero;
    });
  }

  /// Reset to idle without sending
  Future<void> _resetRecording() async {
    _durationTimer?.cancel();
    await _recordingService.cancelRecording();

    if (!mounted) return;
    setState(() {
      _state = RecorderState.idle;
      _recordingDuration = Duration.zero;
    });
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
