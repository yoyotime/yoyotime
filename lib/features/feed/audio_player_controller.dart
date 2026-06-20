import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/content_item.dart';
import '../../domain/event/event_bus_provider.dart';
import '../../domain/event/events.dart';
import '../../core/tts/tts_service.dart';

class AudioPlayerState {
  final List<ContentItem> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isPaused;

  const AudioPlayerState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isPaused = false,
  });

  ContentItem? get current =>
      queue.isNotEmpty && currentIndex < queue.length
          ? queue[currentIndex]
          : null;

  bool get hasMore => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;
  bool get hasQueue => queue.isNotEmpty;
  int get queueLength => queue.length;

  AudioPlayerState copyWith({
    List<ContentItem>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isPaused,
  }) =>
      AudioPlayerState(
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        isPaused: isPaused ?? this.isPaused,
      );
}

class AudioPlayerController extends Notifier<AudioPlayerState> {
  late final TtsService _tts;
  Timer? _queueTimer;

  @override
  AudioPlayerState build() {
    _tts = ref.watch(ttsServiceProvider);

    _tts.addListener(_onTtsStateChanged);

    ref.onDispose(() {
      _tts.removeListener(_onTtsStateChanged);
      _queueTimer?.cancel();
    });

    return const AudioPlayerState();
  }

  void _onTtsStateChanged() {
    if (!_tts.isPlaying && state.isPlaying && !_state.isPaused) {
      _playNext();
    }
  }

  AudioPlayerState get _state => state;

  Future<void> playAll(List<ContentItem> items, {int startIndex = 0}) async {
    if (items.isEmpty) return;

    state = state.copyWith(
      queue: items,
      currentIndex: startIndex,
      isPlaying: true,
      isPaused: false,
    );

    await _playCurrent();
    developer.log('Playing queue: ${items.length} items from $startIndex', name: 'audio');
  }

  Future<void> _playCurrent() async {
    final current = state.current;
    if (current == null) return;

    final text = '${current.title}。${current.fullText ?? current.summary}';
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');

    ref.read(eventBusProvider).publish(
      TtsPlaybackStartedEvent(contentId: current.id),
    );

    await _tts.speak(cleanText);
    developer.log('Playing: ${current.title}', name: 'audio');
  }

  Future<void> _playNext() async {
    if (!state.hasMore) {
      state = state.copyWith(isPlaying: false, isPaused: false);
      developer.log('Queue finished', name: 'audio');
      return;
    }

    state = state.copyWith(currentIndex: state.currentIndex + 1);
    await _playCurrent();
  }

  Future<void> pause() async {
    await _tts.stop();
    state = state.copyWith(isPaused: true);
    developer.log('Paused', name: 'audio');
  }

  Future<void> resume() async {
    if (state.isPaused) {
      await _playCurrent();
      state = state.copyWith(isPaused: false);
      developer.log('Resumed', name: 'audio');
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    state = const AudioPlayerState();
    developer.log('Stopped', name: 'audio');
  }

  Future<void> playNext() async {
    await _tts.stop();
    if (state.hasMore) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      await _playCurrent();
    }
  }

  Future<void> playPrevious() async {
    await _tts.stop();
    if (state.hasPrevious) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
      await _playCurrent();
    }
  }
}

final audioPlayerProvider =
    NotifierProvider<AudioPlayerController, AudioPlayerState>(
        AudioPlayerController.new);
