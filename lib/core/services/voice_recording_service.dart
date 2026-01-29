import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

/// Voice recording and playback service for Talk app
/// Handles microphone permissions, audio recording, and waveform visualization
class VoiceRecordingService {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  RecorderController? _recorderController;
  PlayerController? _playerController;

  String? _currentRecordingPath;
  bool _isInitialized = false;

  /// Get the recorder controller for waveform visualization
  RecorderController? get recorderController => _recorderController;

  /// Get the player controller for playback waveform
  PlayerController? get playerController => _playerController;

  /// Current recording file path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Check if recording is in progress
  bool get isRecording => _recorderController?.isRecording ?? false;

  /// Check if player is playing
  bool get isPlaying => _playerController?.playerState == PlayerState.playing;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    _playerController = PlayerController();
    _isInitialized = true;
  }

  /// Request microphone permission
  /// Returns PermissionResult with status and user-friendly message
  Future<PermissionResult> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return PermissionResult(
        granted: true,
        message: '마이크 권한이 허용되었습니다.',
      );
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult(
        granted: false,
        isPermanentlyDenied: true,
        message: '마이크 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
      );
    }

    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return PermissionResult(
        granted: true,
        message: '마이크 권한이 허용되었습니다.',
      );
    }

    if (result.isPermanentlyDenied) {
      return PermissionResult(
        granted: false,
        isPermanentlyDenied: true,
        message: '마이크 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
      );
    }

    return PermissionResult(
      granted: false,
      message: '음성 녹음을 위해 마이크 권한이 필요합니다.',
    );
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Open app settings for permission management
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Start recording audio
  /// Returns the file path where recording will be saved
  Future<RecordingStartResult> startRecording() async {
    try {
      // Check permission first
      final permissionResult = await requestMicrophonePermission();
      if (!permissionResult.granted) {
        return RecordingStartResult(
          success: false,
          errorMessage: permissionResult.message,
          isPermanentlyDenied: permissionResult.isPermanentlyDenied,
        );
      }

      // Initialize if needed
      await initialize();

      // Generate unique file path
      final directory = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      _currentRecordingPath = '${directory.path}/recording_$uuid.m4a';

      // Start recording
      await _recorderController?.record(path: _currentRecordingPath!);

      return RecordingStartResult(
        success: true,
        filePath: _currentRecordingPath,
      );
    } catch (e) {
      return RecordingStartResult(
        success: false,
        errorMessage: '녹음을 시작할 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    await _recorderController?.pause();
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    await _recorderController?.record();
  }

  /// Stop recording and return the file path
  Future<RecordingStopResult> stopRecording() async {
    try {
      final path = await _recorderController?.stop();

      if (path == null || path.isEmpty) {
        return RecordingStopResult(
          success: false,
          errorMessage: '녹음 파일을 저장할 수 없습니다.',
        );
      }

      // Get duration from the recorded file
      final file = File(path);
      if (!await file.exists()) {
        return RecordingStopResult(
          success: false,
          errorMessage: '녹음 파일을 찾을 수 없습니다.',
        );
      }

      // Prepare player to get duration
      await _playerController?.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );

      final durationMs = _playerController?.maxDuration ?? 0;
      final durationSeconds = (durationMs / 1000).round();

      return RecordingStopResult(
        success: true,
        filePath: path,
        durationMs: durationMs,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      return RecordingStopResult(
        success: false,
        errorMessage: '녹음을 중지할 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// Cancel recording and delete the file
  Future<void> cancelRecording() async {
    await _recorderController?.stop();
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _currentRecordingPath = null;
  }

  /// Prepare player for a specific audio file
  Future<PlayerPrepareResult> preparePlayer(String path) async {
    try {
      await _playerController?.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );

      final durationMs = _playerController?.maxDuration ?? 0;

      return PlayerPrepareResult(
        success: true,
        durationMs: durationMs,
      );
    } catch (e) {
      return PlayerPrepareResult(
        success: false,
        errorMessage: '오디오 파일을 불러올 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// Start playback
  Future<void> startPlayback() async {
    await _playerController?.startPlayer();
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    await _playerController?.pausePlayer();
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _playerController?.stopPlayer();
  }

  /// Seek to a specific position
  Future<void> seekTo(int milliseconds) async {
    await _playerController?.seekTo(milliseconds);
  }

  /// Get waveform data from a file
  Future<List<double>?> extractWaveformData(String path) async {
    try {
      final waveformData = await _playerController?.extractWaveformData(
        path: path,
        noOfSamples: 100,
      );
      return waveformData;
    } catch (e) {
      return null;
    }
  }

  /// Clean up temporary recording files
  Future<void> cleanupTempFiles() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = directory.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('recording_') && file.path.endsWith('.m4a')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Delete a specific recording file
  Future<bool> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dispose controllers
  void dispose() {
    _recorderController?.dispose();
    _playerController?.dispose();
    _recorderController = null;
    _playerController = null;
    _isInitialized = false;
  }

  /// Reset to initial state (for reuse)
  Future<void> reset() async {
    await cancelRecording();
    await stopPlayback();
    _recorderController?.reset();
  }
}

/// Permission request result
class PermissionResult {
  final bool granted;
  final bool isPermanentlyDenied;
  final String message;

  PermissionResult({
    required this.granted,
    this.isPermanentlyDenied = false,
    required this.message,
  });
}

/// Recording start result
class RecordingStartResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final bool isPermanentlyDenied;

  RecordingStartResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    this.isPermanentlyDenied = false,
  });
}

/// Recording stop result
class RecordingStopResult {
  final bool success;
  final String? filePath;
  final int? durationMs;
  final int? durationSeconds;
  final String? errorMessage;

  RecordingStopResult({
    required this.success,
    this.filePath,
    this.durationMs,
    this.durationSeconds,
    this.errorMessage,
  });
}

/// Player prepare result
class PlayerPrepareResult {
  final bool success;
  final int? durationMs;
  final String? errorMessage;

  PlayerPrepareResult({
    required this.success,
    this.durationMs,
    this.errorMessage,
  });
}
