import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TTS播放状态
enum TtsState {
  idle,
  playing,
  paused,
  error,
}

class TtsService extends ChangeNotifier {
  late final FlutterTts _tts;
  bool _initialized = false;
  double _speed = 1.0;
  String? _voice;
  TtsState _state = TtsState.idle;
  String? _lastError;
  String? _currentText;

  /// 最后错误信息
  String? get lastError => _lastError;

  /// 当前播放状态
  TtsState get state => _state;

  /// 是否正在播放
  bool get isPlaying => _state == TtsState.playing;

  /// 是否已暂停
  bool get isPaused => _state == TtsState.paused;

  /// 当前语速
  double get speed => _speed;

  /// 当前语音
  String? get voice => _voice;

  /// 当前播放文本
  String? get currentText => _currentText;

  /// 初始化TTS服务
  Future<void> init({bool skipPlatformInit = false}) async {
    if (_initialized) return;

    try {
      _tts = FlutterTts();
      final prefs = await SharedPreferences.getInstance();
      _speed = prefs.getDouble('tts_speed') ?? 1.0;
      _voice = prefs.getString('tts_voice');

      if (!skipPlatformInit) {
        await _initPlatformTts();
      }

      _initialized = true;
      developer.log('TtsService initialized', name: 'tts');
      notifyListeners();
    } catch (e) {
      _lastError = 'TTS 初始化失败: $e';
      _state = TtsState.error;
      developer.log('Failed to initialize TtsService: $e', name: 'tts');
      notifyListeners();
    }
  }

  /// 初始化平台TTS设置
  Future<void> _initPlatformTts() async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(_speed);

      if (_voice != null && _voice!.isNotEmpty) {
        try {
          await _tts.setVoice(<String, String>{'name': _voice!, 'locale': 'zh-CN'});
        } catch (_) {}
      }

      _tts.setCompletionHandler(() {
        _state = TtsState.idle;
        _currentText = null;
        _lastError = null;
        developer.log('TTS playback completed', name: 'tts');
        notifyListeners();
      });

      _tts.setCancelHandler(() {
        _state = TtsState.idle;
        _currentText = null;
        developer.log('TTS playback cancelled', name: 'tts');
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _state = TtsState.error;
        _lastError = '朗读出错: $msg';
        developer.log('TTS error: $msg', name: 'tts');
        notifyListeners();
      });
    } catch (e) {
      _lastError = 'TTS 平台初始化失败';
      developer.log('Failed to init platform TTS: $e', name: 'tts');
    }
  }

  /// 设置语速
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    notifyListeners();
    if (_initialized) {
      await _tts.setSpeechRate(speed);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speed', speed);
    developer.log('TTS speed set to $speed', name: 'tts');
  }

  /// 获取可用语音列表
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

  /// 设置语音
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
    developer.log('TTS voice set to $name', name: 'tts');
  }

  /// 朗读文本
  Future<void> speak(String text) async {
    try {
      await init();
      await _tts.setSpeechRate(_speed);

      if (isPlaying) {
        await _tts.stop();
      }

      _state = TtsState.playing;
      _currentText = text;
      _lastError = null;
      notifyListeners();

      await _tts.speak(text);
      developer.log('TTS speaking: ${text.substring(0, text.length.clamp(0, 50))}...', name: 'tts');
    } catch (e) {
      _state = TtsState.error;
      _lastError = '朗读失败，请检查语音设置';
      developer.log('TTS speak failed: $e', name: 'tts');
      notifyListeners();
    }
  }

  /// 停止朗读
  Future<void> stop() async {
    if (_initialized) {
      await _tts.stop();
      _state = TtsState.idle;
      _currentText = null;
      developer.log('TTS stopped', name: 'tts');
      notifyListeners();
    }
  }

  /// 暂停朗读
  Future<void> pause() async {
    if (_initialized) {
      await _tts.stop();
      _state = TtsState.paused;
      developer.log('TTS paused', name: 'tts');
      notifyListeners();
    }
  }

  /// 恢复朗读
  Future<void> resume() async {
    if (_state == TtsState.paused && _currentText != null) {
      await speak(_currentText!);
    }
  }

  /// 清除错误状态
  void clearError() {
    if (_state == TtsState.error) {
      _state = TtsState.idle;
      _lastError = null;
      notifyListeners();
    }
  }
}

final ttsServiceProvider = ChangeNotifierProvider<TtsService>((ref) {
  return TtsService();
});
