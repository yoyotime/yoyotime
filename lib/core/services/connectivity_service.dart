import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get status => _controller.stream;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  ConnectivityStatus get currentStatus => _currentStatus;

  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _currentStatus = result == ConnectivityResult.none
          ? ConnectivityStatus.offline
          : ConnectivityStatus.online;
      _controller.add(_currentStatus);
    });

    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _currentStatus = result == ConnectivityResult.none
          ? ConnectivityStatus.offline
          : ConnectivityStatus.online;
      _controller.add(_currentStatus);
    } catch (_) {
      _currentStatus = ConnectivityStatus.unknown;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.status;
});
