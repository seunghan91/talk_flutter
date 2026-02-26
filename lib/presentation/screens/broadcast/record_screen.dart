import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  final VoiceRecordingService _recordingService = VoiceRecordingService();

  late AnimationController _pulseAnimationController;
  Timer? _durationTimer;

  // Recording state
  RecordingState _state = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  String? _recordedFilePath;
  int? _recordedDurationSeconds;
  String? _errorMessage;

  // Gender selection
  String _selectedGender = 'female'; // 'male' | 'female' | 'all'

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
      HapticFeedback.heavyImpact();
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
      HapticFeedback.mediumImpact();
      setState(() {
        _state = RecordingState.recorded;
        _recordedFilePath = result.filePath;
        _recordedDurationSeconds =
            result.durationSeconds ?? _recordingDuration.inSeconds;
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

    context.read<BroadcastBloc>().add(BroadcastCreateRequested(
      audioPath: _recordedFilePath!,
      duration: _recordedDurationSeconds!,
      recipientCount: 5,
    ));

    context.pop();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('마이크 권한 필요'),
        content: const Text(
          '음성 녹음을 위해 마이크 권한이 필요합니다.\n설정에서 권한을 허용해주세요.',
        ),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<BroadcastBloc, BroadcastState>(
      listener: (context, state) {
        if (state.status == BroadcastStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? '전송에 실패했습니다'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Custom header
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      AppSpacing.verticalSm,

                      // Gender selector card
                      _buildGenderSelectorCard(),
                      AppSpacing.verticalMd,

                      // Recorder card
                      _buildRecorderCard(),

                      AppSpacing.verticalMd,

                      // Remaining time hint
                      if (_state == RecordingState.recording)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              child: LinearProgressIndicator(
                                value: _recordingDuration.inSeconds /
                                    _maxDurationSeconds,
                                backgroundColor: context.mutedColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                                minHeight: 4,
                              ),
                            ),
                            AppSpacing.verticalXs,
                            Text(
                              '${_maxDurationSeconds - _recordingDuration.inSeconds}초 남음',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.mutedForegroundColor,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '최대 $_maxDurationSeconds초까지 녹음할 수 있습니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.mutedForegroundColor,
                          ),
                        ),

                      AppSpacing.verticalXxl,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          bottom: BorderSide(color: context.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: context.textPrimary,
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
          Expanded(
            child: Center(
              child: Text(
                '새 보이스 보내기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGenderSelectorCard() {
    return _DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '보낼 대상 성별',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.mutedForegroundColor,
            ),
          ),
          AppSpacing.verticalSm,
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  label: '여성',
                  icon: Icons.female_rounded,
                  isSelected: _selectedGender == 'female',
                  onTap: () => setState(() => _selectedGender = 'female'),
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: _GenderButton(
                  label: '남성',
                  icon: Icons.male_rounded,
                  isSelected: _selectedGender == 'male',
                  onTap: () => setState(() => _selectedGender = 'male'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderCard() {
    final isRecording = _state == RecordingState.recording;
    final isRecorded = _state == RecordingState.recorded;
    final hasError = _state == RecordingState.error ||
        _state == RecordingState.permissionDenied;
    final isProcessing = _state == RecordingState.starting ||
        _state == RecordingState.stopping;
    final isIdle = _state == RecordingState.idle ||
        _state == RecordingState.error ||
        _state == RecordingState.permissionDenied;

    return _DesignCard(
      child: Column(
        children: [
          AppSpacing.verticalSm,

          // Waveform or mic visualization
          if (isRecording && _recordingService.recorderController != null)
            SizedBox(
              height: 80,
              child: AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width - 80, 70),
                recorderController: _recordingService.recorderController!,
                waveStyle: WaveStyle(
                  waveColor: AppColors.primary,
                  extendWaveform: true,
                  showMiddleLine: false,
                  spacing: 8.0,
                  waveThickness: 4.0,
                  showDurationLabel: false,
                  durationStyle: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                  ),
                ),
                enableGesture: false,
              ),
            )
          else
            const SizedBox(height: 16),

          AppSpacing.verticalMd,

          // Large mic button with pulse
          AnimatedBuilder(
            animation: _pulseAnimationController,
            builder: (context, child) {
              final pulse = isRecording
                  ? _pulseAnimationController.value * 16.0
                  : 0.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  if (isRecording)
                    Container(
                      width: 80 + pulse * 2,
                      height: 80 + pulse * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  // Main button
                  Material(
                    shape: const CircleBorder(),
                    color: isProcessing
                        ? context.mutedColor
                        : isRecorded
                            ? context.mutedColor
                            : isRecording
                                ? AppColors.primary
                                : AppColors.primary,
                    elevation: isProcessing || isRecorded ? 0 : 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    child: InkWell(
                      onTap: isProcessing
                          ? null
                          : isRecording
                              ? _stopRecording
                              : isIdle
                                  ? _startRecording
                                  : null,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: isProcessing
                            ? Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                isRecording
                                    ? Icons.stop_rounded
                                    : isRecorded
                                        ? Icons.check_rounded
                                        : hasError
                                            ? Icons.mic_off_rounded
                                            : Icons.mic_rounded,
                                color: isRecorded || hasError
                                    ? context.mutedForegroundColor
                                    : Colors.white,
                                size: 36,
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          AppSpacing.verticalMd,

          // Duration timer
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          AppSpacing.verticalXs,

          // Status text
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 13,
              color: hasError ? AppColors.primary : context.mutedForegroundColor,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalMd,

          // Control row: reset | (gap) | send
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset / Cancel
              if (isRecorded)
                _ControlButton(
                  icon: Icons.refresh_rounded,
                  label: '다시',
                  backgroundColor: context.mutedColor,
                  foregroundColor: context.mutedForegroundColor,
                  onPressed: _resetRecording,
                )
              else if (isRecording)
                _ControlButton(
                  icon: Icons.close_rounded,
                  label: '취소',
                  backgroundColor: context.mutedColor,
                  foregroundColor: AppColors.primary,
                  onPressed: _cancelRecording,
                )
              else
                const SizedBox(width: 72),

              const SizedBox(width: AppSpacing.xxl),

              // Send
              if (isRecorded)
                BlocBuilder<BroadcastBloc, BroadcastState>(
                  builder: (context, state) {
                    final isSending = state.status == BroadcastStatus.creating;
                    return _ControlButton(
                      icon: Icons.send_rounded,
                      label: '보내기',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: isSending ? () {} : _sendBroadcast,
                      isLoading: isSending,
                    );
                  },
                )
              else
                const SizedBox(width: 72),
            ],
          ),

          AppSpacing.verticalSm,
        ],
      ),
    );
  }
}

// ─── Design card helper ────────────────────────────────────────────────────────

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

// ─── Gender button ────────────────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : context.mutedForegroundColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : context.mutedForegroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Control button (reset / send) ────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final bool isLoading;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    ),
                  )
                : Icon(icon, color: foregroundColor, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.mutedForegroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
