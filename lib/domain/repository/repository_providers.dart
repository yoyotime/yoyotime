import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/feed/feed_fetcher.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/repository/feed_source_repository.dart';
import '../../domain/repository/content_repository.dart';
import '../../domain/repository/preferences_repository.dart';

final feedSourceRepositoryProvider = Provider<FeedSourceRepository>((ref) {
  return FeedFetcher();
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ref.watch(storageServiceProvider);
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return ref.watch(storageServiceProvider);
});

// Legacy alias for backward compatibility
final feedFetcherProvider = Provider<FeedFetcher>((ref) {
  return FeedFetcher();
});
