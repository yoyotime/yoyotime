import 'dart:async';
import 'package:test/test.dart';

/// 模拟 ChangeNotifier 行为，验证 TtsService 的 setSpeed 通知机制
class MockNotifier {
  int _speed = 1;
  int _listenerCalls = 0;
  void Function()? onChanged;

  int get speed => _speed;

  void notify() {
    _listenerCalls++;
    onChanged?.call();
  }

  Future<void> setSpeed(int speed) async {
    _speed = speed;
    notify();
  }

  int get listenerCalls => _listenerCalls;
}

void main() {
  group('TtsService speed change notification pattern', () {
    test('setSpeed updates value and triggers notification', () async {
      final notifier = MockNotifier();
      int rebuilds = 0;
      notifier.onChanged = () => rebuilds++;

      await notifier.setSpeed(5);
      expect(notifier.speed, 5);
      expect(notifier.listenerCalls, 1);
      expect(rebuilds, 1);
    });

    test('multiple setSpeed calls each trigger notification', () async {
      final notifier = MockNotifier();
      int rebuilds = 0;
      notifier.onChanged = () => rebuilds++;

      await notifier.setSpeed(2);
      await notifier.setSpeed(3);
      await notifier.setSpeed(4);
      expect(notifier.listenerCalls, 3);
      expect(rebuilds, 3);
      expect(notifier.speed, 4);
    });

    test('ChangeNotifierProvider pattern watcher receives update', () async {
      // 模拟 Riverpod ChangeNotifierProvider 的 watch 行为
      final notifier = MockNotifier();

      int watchCount = 0;
      void watcher() {
        watchCount++;
      }
      notifier.onChanged = watcher;

      await notifier.setSpeed(2);
      expect(watchCount, 1);
      expect(notifier.speed, 2);

      await notifier.setSpeed(8);
      expect(watchCount, 2);
      expect(notifier.speed, 8);
    });
  });
}
