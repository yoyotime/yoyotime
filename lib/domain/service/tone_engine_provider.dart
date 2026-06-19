import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tone_engine.dart';

final toneEngineProvider = Provider<ToneEngine>((ref) {
  return ToneEngine();
});
