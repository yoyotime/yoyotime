import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyotime/core/tts/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TtsService', () {
    test('extends ChangeNotifier', () {
      final service = TtsService();
      expect(service, isA<ChangeNotifier>());
    });

    test('default speed is 1.0', () {
      final service = TtsService();
      expect(service.speed, 1.0);
    });

    test('setSpeed updates speed and notifies listeners', () async {
      final service = TtsService();
      final provider = ChangeNotifierProvider<TtsService>((ref) => service);

      int notifyCount = 0;
      service.addListener(() {
        notifyCount++;
      });

      await service.setSpeed(1.5);
      expect(service.speed, 1.5);
      expect(notifyCount, 1);

      await service.setSpeed(0.8);
      expect(service.speed, 0.8);
      expect(notifyCount, 2);
    });

    test('setSpeed persists to SharedPreferences', () async {
      final service = TtsService();

      await service.setSpeed(1.5);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('tts_speed'), 1.5);

      await service.setSpeed(0.8);
      final prefs2 = await SharedPreferences.getInstance();
      expect(prefs2.getDouble('tts_speed'), 0.8);
    });

    test('loads persisted speed on init', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_speed', 0.8);

      final service = TtsService();
      expect(service.speed, 0.8);
    });

    test('provider is ChangeNotifierProvider', () {
      final container = ProviderContainer();
      final provider = ttsServiceProvider;
      final service = container.read(provider);
      expect(service, isA<TtsService>());
      container.dispose();
    });
  });
}
