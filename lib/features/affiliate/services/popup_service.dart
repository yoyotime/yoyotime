import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopupService {
  Timer? _timer;
  bool _enabled = true;
  void Function()? onShowPopup;

  void start() {
    _scheduleNext();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNext() {
    if (!_enabled) return;
    _timer?.cancel();
    final delay = Duration(
      milliseconds: 30000 + DateTime.now().millisecond % 90000,
    );
    _timer = Timer(delay, () {
      onShowPopup?.call();
      _scheduleNext();
    });
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (enabled) {
      _scheduleNext();
    } else {
      _timer?.cancel();
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

final popupServiceProvider = Provider<PopupService>((ref) {
  final service = PopupService();
  ref.onDispose(() => service.dispose());
  return service;
});
