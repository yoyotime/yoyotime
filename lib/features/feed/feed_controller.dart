import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../shared/models/content.dart';

class FeedState {
  final List<ContentItem> items;
  final bool isLoading;
  final bool isOffline;
  final String? error;
  final DateTime? lastUpdated;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.error,
    this.lastUpdated,
  });

  FeedState copyWith({
    List<ContentItem>? items,
    bool? isLoading,
    bool? isOffline,
    String? error,
    DateTime? lastUpdated,
  }) =>
      FeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isOffline: isOffline ?? this.isOffline,
        error: error,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

class FeedController extends Notifier<FeedState> {
  late final ApiClient _api;
  late final StorageService _storage;

  @override
  FeedState build() {
    _api = ref.watch(apiClientProvider);
    _storage = ref.watch(storageServiceProvider);
    Future.microtask(load);
    return const FeedState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final cached = await _storage.getCachedContents();
    if (cached.isNotEmpty) {
      state = state.copyWith(items: cached, isLoading: false);
    }

    try {
      final userId = await _ensureUserId();
      final feed = await _api.fetchFeed(userId: userId, size: 30);
      await _storage.saveCachedContents(feed.items);
      state = state.copyWith(
        items: feed.items,
        isLoading: false,
        isOffline: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isOffline: true,
        error: e is ApiException ? e.message : '获取内容失败',
      );
    }
  }

  Future<String> _ensureUserId() async {
    return _storage.getOrCreateUserId();
  }

  Future<void> actOnContent(ContentItem item, FeedbackAction action) async {
    await _storage.setFeedback(item.id, action);
    if (action == FeedbackAction.delete || action == FeedbackAction.dislike) {
      final updated = state.items.where((c) => c.id != item.id).toList();
      state = state.copyWith(items: updated);
    }
  }
}

final feedControllerProvider =
    NotifierProvider<FeedController, FeedState>(FeedController.new);
