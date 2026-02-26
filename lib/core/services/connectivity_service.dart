import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Centralized network connectivity monitoring.
/// Exposes a stream and synchronous getter for online/offline state.
class ConnectivityService {
  final Connectivity _connectivity;
  late final StreamController<bool> _controller;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _controller = StreamController<bool>.broadcast();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(result);
    _controller.add(_isOnline);
  }

  void _onChanged(ConnectivityResult result) {
    final online = _hasConnection(result);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
    }
  }

  bool _hasConnection(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
