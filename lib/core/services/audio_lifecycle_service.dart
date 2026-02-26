import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

/// Manages audio playback lifecycle when the app transitions between
/// foreground and background states.
///
/// Policy:
/// - Pause active playback when app goes to background
/// - Optionally resume when app returns to foreground
class AudioLifecycleService with WidgetsBindingObserver {
  static final _log = Logger(printer: SimplePrinter());

  AudioPlayer? _activePlayer;
  bool _wasPlayingBeforeBackground = false;
  bool resumeOnForeground;

  AudioLifecycleService({this.resumeOnForeground = true});

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activePlayer = null;
  }

  /// Register the currently active audio player so lifecycle events can
  /// pause/resume it.
  void registerPlayer(AudioPlayer? player) {
    _activePlayer = player;
  }

  void unregisterPlayer(AudioPlayer? player) {
    if (_activePlayer == player) {
      _activePlayer = null;
      _wasPlayingBeforeBackground = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _onBackground();
        break;
      case AppLifecycleState.resumed:
        _onForeground();
        break;
      default:
        break;
    }
  }

  void _onBackground() {
    final player = _activePlayer;
    if (player == null) return;

    _wasPlayingBeforeBackground = player.playing;
    if (player.playing) {
      _log.d('AudioLifecycle: pausing playback (app backgrounded)');
      player.pause();
    }
  }

  void _onForeground() {
    final player = _activePlayer;
    if (player == null) return;

    if (_wasPlayingBeforeBackground && resumeOnForeground) {
      _log.d('AudioLifecycle: resuming playback (app foregrounded)');
      player.play();
    }
    _wasPlayingBeforeBackground = false;
  }
}
