import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService extends ChangeNotifier {
  late final FlutterTts _tts;
  bool _initialized = false;
  double _speed = 1.0;
  String? _voice;
  bool _isPlaying = false;

  Future<void> init({bool skipPlatformInit = false}) async {
    if (_initialized) return;
    _tts = FlutterTts();
    final prefs = await SharedPreferences.getInstance();
    _speed = prefs.getDouble('tts_speed') ?? 1.0;
    _voice = prefs.getString('tts_voice');

    if (!skipPlatformInit) {
      await _tts.setLanguage('zh-CN');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(_speed);
      if (_voice != null) {
        final voiceName = _voice!;
        try {
          await _tts.setVoice(<String, String>{'name': voiceName, 'locale': 'zh-CN'});
        } catch (_) {}
      }

      _tts.setCompletionHandler(() {
        _isPlaying = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        _isPlaying = false;
        notifyListeners();
      });
      _tts.setErrorHandler((msg) {
        _isPlaying = false;
        notifyListeners();
      });
    }

    _initialized = true;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;
  double get speed => _speed;
  String? get voice => _voice;

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    notifyListeners();
    if (_initialized) {
      await _tts.setSpeechRate(speed);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speed', speed);
  }

  Future<List<Map<String, String>>> getVoices() async {
    await init();
    try {
      final list = await _tts.getVoices;
      if (list is List) {
        return list
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v.toString())))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> setVoice(String? name) async {
    _voice = name;
    notifyListeners();
    if (_initialized && name != null) {
      try {
        await _tts.setVoice({'name': name, 'locale': 'zh-CN'});
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice', name ?? '');
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.setSpeechRate(_speed);
    if (_isPlaying) {
      await _tts.stop();
    }
    _isPlaying = true;
    notifyListeners();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (_initialized) {
      await _tts.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_initialized) {
      try {
        await _tts.pause();
      } catch (_) {}
    }
  }
}

final ttsServiceProvider = ChangeNotifierProvider<TtsService>((ref) {
  return TtsService();
});
