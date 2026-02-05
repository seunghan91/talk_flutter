import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_flutter/core/services/voice_recording_service.dart';
import 'package:talk_flutter/core/theme/theme.dart';
import 'package:talk_flutter/presentation/blocs/broadcast/broadcast_bloc.dart';

/// Broadcast recording screen with real audio recording and waveform visualization
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with SingleTickerProviderStateMixin {
  final VoiceRecordingService _recordingService = VoiceRecordingService();

  late AnimationController _pulseAnimationController;
  Timer? _durationTimer;

  // Recording state
  RecordingState _state = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  String? _recordedFilePath;
  int? _recordedDurationSeconds;
  String? _errorMessage;

  // Max recording duration: 60 seconds
  static const int _maxDurationSeconds = 60;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  Future<void> _initializeService() async {
    await _recordingService.initialize();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseAnimationController.dispose();
    _recordingService.reset();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _state = RecordingState.starting;
      _errorMessage = null;
    });

    final result = await _recordingService.startRecording();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _state = RecordingState.recording;
        _recordingDuration = Duration.zero;
      });
      _startDurationTimer();
    } else {
      setState(() {
        _state = RecordingState.permissionDenied;
        _errorMessage = result.errorMessage;
      });

      if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
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

      // Auto-stop at max duration
      if (_recordingDuration.inSeconds >= _maxDurationSeconds) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _durationTimer?.cancel();

    setState(() {
      _state = RecordingState.stopping;
    });

    final result = await _recordingService.stopRecording();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _state = RecordingState.recorded;
        _recordedFilePath = result.filePath;
        _recordedDurationSeconds = result.durationSeconds ?? _recordingDuration.inSeconds;
      });
    } else {
      setState(() {
        _state = RecordingState.error;
        _errorMessage = result.errorMessage;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _durationTimer?.cancel();
    await _recordingService.cancelRecording();

    if (!mounted) return;

    setState(() {
      _state = RecordingState.idle;
      _recordingDuration = Duration.zero;
      _recordedFilePath = null;
      _recordedDurationSeconds = null;
    });
  }

  Future<void> _resetRecording() async {
    if (_recordedFilePath != null) {
      await _recordingService.deleteRecording(_recordedFilePath!);
    }

    setState(() {
      _state = RecordingState.idle;
      _recordingDuration = Duration.zero;
      _recordedFilePath = null;
      _recordedDurationSeconds = null;
      _errorMessage = null;
    });
  }

  void _sendBroadcast() {
    if (_recordedFilePath == null || _recordedDurationSeconds == null) return;

    // Send broadcast via BLoC
    context.read<BroadcastBloc>().add(BroadcastCreateRequested(
      audioPath: _recordedFilePath!,
      duration: _recordedDurationSeconds!,
      recipientCount: 5, // Default recipient count
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('브로드캐스트를 전송 중입니다...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    context.pop();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('마이크 권한 필요'),
        content: const Text(
          '음성 녹음을 위해 마이크 권한이 필요합니다.\n설정에서 권한을 허용해주세요.',
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
            child: const Text('설정으로 이동'),
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
    return BlocListener<BroadcastBloc, BroadcastState>(
      listener: (context, state) {
        if (state.status == BroadcastStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? '전송에 실패했습니다'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('새 브로드캐스트'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final navigator = GoRouter.of(context);
              if (_state == RecordingState.recording) {
                await _cancelRecording();
              } else if (_recordedFilePath != null) {
                await _recordingService.deleteRecording(_recordedFilePath!);
              }
              if (!mounted) return;
              navigator.pop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),

                // Recording visualization
                _buildRecordingVisualization(),

                AppSpacing.verticalXxl,

                // Timer
                Text(
                  _formatDuration(_recordingDuration),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),

                AppSpacing.verticalXs,

                // Status text
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _state == RecordingState.error ||
                                _state == RecordingState.permissionDenied
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Recording controls
                _buildRecordingControls(),

                AppSpacing.verticalXxl,

                // Progress indicator
                if (_state == RecordingState.recording)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _recordingDuration.inSeconds / _maxDurationSeconds,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        '${_maxDurationSeconds - _recordingDuration.inSeconds}초 남음',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  )
                else
                  Text(
                    '최대 $_maxDurationSeconds초까지 녹음할 수 있습니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),

                AppSpacing.verticalMd,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingVisualization() {
    final isRecording = _state == RecordingState.recording;
    final isRecorded = _state == RecordingState.recorded;
    final hasError = _state == RecordingState.error ||
        _state == RecordingState.permissionDenied;

    // Show waveform during recording
    if (isRecording && _recordingService.recorderController != null) {
      return Container(
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AudioWaveforms(
          size: Size(MediaQuery.of(context).size.width - 80, 150),
          recorderController: _recordingService.recorderController!,
          waveStyle: WaveStyle(
            waveColor: Theme.of(context).colorScheme.error,
            extendWaveform: true,
            showMiddleLine: false,
            spacing: 8.0,
            waveThickness: 4.0,
            showDurationLabel: false,
            durationStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          enableGesture: false,
        ),
      );
    }

    // Show animated circle for idle/recorded states
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        final pulseValue = isRecording ? _pulseAnimationController.value * 30 : 0.0;

        return Container(
          width: 200 + pulseValue,
          height: 200 + pulseValue,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? Theme.of(context).colorScheme.errorContainer
                : isRecorded
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasError
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2)
                    : isRecorded
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                _getStateIcon(),
                size: AppIconSize.hero,
                color: hasError
                    ? Theme.of(context).colorScheme.error
                    : isRecorded
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStateIcon() {
    switch (_state) {
      case RecordingState.idle:
      case RecordingState.starting:
        return Icons.mic_none;
      case RecordingState.recording:
        return Icons.mic;
      case RecordingState.stopping:
        return Icons.hourglass_empty;
      case RecordingState.recorded:
        return Icons.check_circle;
      case RecordingState.error:
      case RecordingState.permissionDenied:
        return Icons.error_outline;
    }
  }

  String _getStatusText() {
    switch (_state) {
      case RecordingState.idle:
        return '버튼을 눌러 녹음을 시작하세요';
      case RecordingState.starting:
        return '녹음 준비 중...';
      case RecordingState.recording:
        return '녹음 중...';
      case RecordingState.stopping:
        return '저장 중...';
      case RecordingState.recorded:
        return '녹음 완료! 전송하거나 다시 녹음하세요';
      case RecordingState.error:
        return _errorMessage ?? '오류가 발생했습니다';
      case RecordingState.permissionDenied:
        return _errorMessage ?? '마이크 권한이 필요합니다';
    }
  }

  Widget _buildRecordingControls() {
    final isIdle = _state == RecordingState.idle ||
        _state == RecordingState.error ||
        _state == RecordingState.permissionDenied;
    final isRecording = _state == RecordingState.recording;
    final isRecorded = _state == RecordingState.recorded;
    final isProcessing = _state == RecordingState.starting ||
        _state == RecordingState.stopping;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset/Cancel button
        if (isRecorded)
          IconButton.filled(
            onPressed: _resetRecording,
            icon: const Icon(Icons.refresh),
            iconSize: AppIconSize.xl,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              minimumSize: const Size(AppIconSize.hero, AppIconSize.hero),
            ),
          )
        else if (isRecording)
          IconButton.filled(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.close),
            iconSize: AppIconSize.xl,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              minimumSize: const Size(AppIconSize.hero, AppIconSize.hero),
            ),
          )
        else
          const SizedBox(width: AppIconSize.hero),

        // Main record/stop button
        GestureDetector(
          onTap: isProcessing
              ? null
              : (isRecording ? _stopRecording : (isIdle ? _startRecording : null)),
          child: Container(
            width: AppIconSize.heroLarge,
            height: AppIconSize.heroLarge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : isRecording
                      ? Theme.of(context).colorScheme.error
                      : isRecorded
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : Theme.of(context).colorScheme.primary,
              boxShadow: isProcessing || isRecorded
                  ? null
                  : [
                      BoxShadow(
                        color: (isRecording
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
            ),
            child: isProcessing
                ? Center(
                    child: SizedBox(
                      width: AppIconSize.xl,
                      height: AppIconSize.xl,
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : Icon(
                    isRecording
                        ? Icons.stop
                        : isRecorded
                            ? Icons.mic
                            : Icons.mic,
                    color: isRecorded
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onPrimary,
                    size: AppIconSize.xl + AppIconSize.xs,
                  ),
          ),
        ),

        // Send button
        if (isRecorded)
          BlocBuilder<BroadcastBloc, BroadcastState>(
            builder: (context, state) {
              final isSending = state.status == BroadcastStatus.creating;

              return IconButton.filled(
                onPressed: isSending ? null : _sendBroadcast,
                icon: isSending
                    ? SizedBox(
                        width: AppIconSize.lg,
                        height: AppIconSize.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send),
                iconSize: AppIconSize.xl,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(AppIconSize.hero, AppIconSize.hero),
                ),
              );
            },
          )
        else
          const SizedBox(width: AppIconSize.hero),
      ],
    );
  }
}

/// Recording state machine
enum RecordingState {
  idle,
  starting,
  recording,
  stopping,
  recorded,
  error,
  permissionDenied,
}
