import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_flutter/core/theme/app_colors.dart';
import 'package:talk_flutter/core/theme/app_spacing.dart';
import 'package:talk_flutter/data/services/audio_cache_service.dart';

/// Voice message player widget with waveform visualization
/// Used for playing back recorded voice messages in conversations
class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final int? durationSeconds;
  final bool isSentByMe;
  final VoidCallback? onPlayStateChanged;
  final String? sourceType;
  final int? sourceId;

  /// When true, renders in standalone broadcast mode (large 64px button)
  final bool isStandalone;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    this.durationSeconds,
    this.isSentByMe = false,
    this.onPlayStateChanged,
    this.sourceType,
    this.sourceId,
    this.isStandalone = false,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late PlayerController _playerController;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<int>? _durationSubscription;

  bool _isPlaying = false;
  bool _isPrepared = false;
  bool _hasError = false;
  int _currentPosition = 0;
  int _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      String audioPath = widget.audioUrl;
      if (widget.sourceType != null && widget.sourceId != null) {
        try {
          final cacheService = context.read<AudioCacheService>();
          audioPath = await cacheService.resolveAudioPath(
            sourceType: widget.sourceType!,
            sourceId: widget.sourceId!,
            remoteUrl: widget.audioUrl,
          );
        } catch (_) {
          // Fall back to remote URL on any error
        }
      }

      await _playerController.preparePlayer(
        path: audioPath,
        shouldExtractWaveform: true,
        noOfSamples: 50,
      );

      _totalDuration = _playerController.maxDuration;

      _playerStateSubscription =
          _playerController.onPlayerStateChanged.listen((state) {
        if (!mounted) return;

        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        widget.onPlayStateChanged?.call();

        if (state == PlayerState.stopped || state == PlayerState.paused) {
          // Reset position when playback ends
        }
      });

      _durationSubscription =
          _playerController.onCurrentDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() {
          _currentPosition = duration;
        });
      });

      setState(() {
        _isPrepared = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (!_isPrepared || _hasError) return;

    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
    }
  }

  Future<void> _replay() async {
    if (!_isPrepared || _hasError) return;
    await _playerController.seekTo(0);
    await _playerController.startPlayer();
  }

  String _formatDuration(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int get _displayTotalMs =>
      widget.durationSeconds != null
          ? widget.durationSeconds! * 1000
          : _totalDuration;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Semantics(
        label: '음성 메시지 재생 오류',
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: AppIconSize.md,
              ),
              AppSpacing.horizontalXs,
              const Text(
                '재생할 수 없음',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isStandalone) {
      return _buildStandalonePlayer();
    }

    return _buildChatPlayer();
  }

  // -------------------------------------------------------------------------
  // Standalone (broadcast) player - large 64px button
  // -------------------------------------------------------------------------
  Widget _buildStandalonePlayer() {
    return Semantics(
      label: '음성 메시지 플레이어',
      hint: _isPlaying ? '탭하여 일시정지' : '탭하여 재생',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large play/pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: !_isPrepared
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                      semanticLabel: _isPlaying ? '일시정지' : '재생',
                    ),
            ),
          ),
          AppSpacing.verticalSm,

          // Waveform
          if (_isPrepared)
            SizedBox(
              width: 200,
              height: 36,
              child: AudioFileWaveforms(
                size: const Size(200, 36),
                playerController: _playerController,
                enableSeekGesture: true,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: AppColors.primary.withValues(alpha: 0.25),
                  liveWaveColor: AppColors.primary,
                  spacing: 4,
                  waveThickness: 3,
                  seekLineColor: AppColors.primary,
                  showSeekLine: false,
                ),
              ),
            )
          else
            SizedBox(
              width: 200,
              height: 36,
              child: Center(
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  color: AppColors.primary,
                ),
              ),
            ),
          AppSpacing.verticalXs,

          // Time + replay row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current / total time
              Text(
                '${_formatDuration(_currentPosition)} / ${_formatDuration(_displayTotalMs)}',
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              AppSpacing.horizontalSm,

              // Replay button
              GestureDetector(
                onTap: _isPrepared ? _replay : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: -0.5,
                        child: const Icon(
                          Icons.replay_rounded,
                          size: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '다시듣기',
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Chat bubble player - compact with isSentByMe styling
  // -------------------------------------------------------------------------
  Widget _buildChatPlayer() {
    // Button styling per sender context
    final Color buttonBg = widget.isSentByMe
        ? Colors.white.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.1);
    final Color iconColor =
        widget.isSentByMe ? Colors.white : AppColors.primary;

    // Progress bar colors
    final Color progressPlayed =
        widget.isSentByMe ? Colors.white : AppColors.primary;
    final Color progressRemaining = widget.isSentByMe
        ? Colors.white.withValues(alpha: 0.3)
        : AppColors.neutral300;

    // Time text color
    final Color timeColor = widget.isSentByMe
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.mutedForeground;

    return Semantics(
      label: '음성 메시지 플레이어',
      hint: _isPlaying ? '탭하여 일시정지' : '탭하여 재생',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause button - 40px in chat
              Tooltip(
                message: _isPlaying ? '일시정지' : '재생',
                child: Semantics(
                  button: true,
                  label: _isPlaying ? '일시정지' : '재생',
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonBg,
                      ),
                      child: !_isPrepared
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: iconColor,
                              ),
                            )
                          : Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: iconColor,
                              size: AppIconSize.lg,
                            ),
                    ),
                  ),
                ),
              ),

              AppSpacing.horizontalXs,

              // Waveform
              if (_isPrepared)
                SizedBox(
                  width: 120,
                  height: 36,
                  child: AudioFileWaveforms(
                    size: const Size(120, 36),
                    playerController: _playerController,
                    enableSeekGesture: true,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: progressRemaining,
                      liveWaveColor: progressPlayed,
                      spacing: 4,
                      waveThickness: 3,
                      seekLineColor: progressPlayed,
                      showSeekLine: false,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 120,
                  height: 36,
                  child: Center(
                    child: LinearProgressIndicator(
                      backgroundColor: progressRemaining,
                      color: progressPlayed,
                    ),
                  ),
                ),

              AppSpacing.horizontalXs,

              // Time column: current / total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    _formatDuration(_displayTotalMs),
                    style: TextStyle(
                      color: timeColor.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Progress bar (thin, 2px)
          const SizedBox(height: 6),
          SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: _totalDuration > 0
                    ? _currentPosition / _totalDuration
                    : 0,
                minHeight: 2,
                backgroundColor: progressRemaining,
                color: progressPlayed,
              ),
            ),
          ),

          // Replay button
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _isPrepared ? _replay : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.replay_rounded,
                    size: 11,
                    color: timeColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '다시듣기',
                  style: TextStyle(
                    color: timeColor.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
