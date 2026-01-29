import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

/// Voice message player widget with waveform visualization
/// Used for playing back recorded voice messages in conversations
class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final int? durationSeconds;
  final bool isSentByMe;
  final VoidCallback? onPlayStateChanged;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    this.durationSeconds,
    this.isSentByMe = false,
    this.onPlayStateChanged,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late PlayerController _playerController;
  StreamSubscription<PlayerState>? _playerStateSubscription;

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
      await _playerController.preparePlayer(
        path: widget.audioUrl,
        shouldExtractWaveform: true,
        noOfSamples: 50,
      );

      _totalDuration = _playerController.maxDuration;

      _playerStateSubscription = _playerController.onPlayerStateChanged.listen((state) {
        if (!mounted) return;

        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        widget.onPlayStateChanged?.call();

        if (state == PlayerState.stopped || state == PlayerState.paused) {
          // Reset position when playback ends
        }
      });

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

  String _formatDuration(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Colors based on message sender
    final backgroundColor = widget.isSentByMe
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = widget.isSentByMe
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final waveColor = widget.isSentByMe
        ? colorScheme.primary
        : colorScheme.tertiary;

    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '재생할 수 없음',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: waveColor,
              ),
              child: !_isPrepared
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Waveform or progress
          if (_isPrepared)
            Flexible(
              child: SizedBox(
                width: 150,
                height: 40,
                child: AudioFileWaveforms(
                  size: const Size(150, 40),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: waveColor.withValues(alpha: 0.3),
                    liveWaveColor: waveColor,
                    spacing: 4,
                    waveThickness: 3,
                    seekLineColor: waveColor,
                    showSeekLine: false,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: 150,
              height: 40,
              child: Center(
                child: LinearProgressIndicator(
                  backgroundColor: waveColor.withValues(alpha: 0.2),
                  color: waveColor,
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Duration
          Text(
            _isPlaying
                ? _formatDuration(_currentPosition)
                : _formatDuration(widget.durationSeconds != null
                    ? widget.durationSeconds! * 1000
                    : _totalDuration),
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
