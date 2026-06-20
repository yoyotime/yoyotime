import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tone_engine.dart';

final toneEngineProvider = Provider<ToneEngine>((ref) {
  final engine = ToneEngine();
  ref.onDispose(() {
    // Cleanup if needed
  });
  return engine;
});

// Async provider that loads rules
final toneEngineAsyncProvider = FutureProvider<ToneEngine>((ref) async {
  final engine = ToneEngine();
  await engine.loadRules();
  return engine;
});
