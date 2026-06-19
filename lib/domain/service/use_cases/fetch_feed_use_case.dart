import '../../model/content_item.dart';
import '../../repository/feed_source_repository.dart';
import '../../repository/content_repository.dart';
import '../tone_engine.dart';

class FeedResult {
  final List<ContentItem> items;
  final int totalCount;
  final List<String> failedSources;
  final bool isEmpty;

  const FeedResult({
    required this.items,
    required this.totalCount,
    this.failedSources = const [],
    this.isEmpty = false,
  });
}

class FetchFeedUseCase {
  final FeedSourceRepository _feedSource;
  final ToneEngine _tone;

  FetchFeedUseCase(this._feedSource, this._tone);

  Future<FeedResult> execute({
    required List<String> blocklist,
    required Map<String, dynamic> feedback,
    int maxItems = 10,
  }) async {
    final allItems = await _feedSource.fetchAll();

    var filtered = _tone.filter(allItems);

    filtered = filtered.where((item) => !item.matchesBlocklist(blocklist)).toList();

    filtered = filtered.where((item) {
      final fb = feedback[item.id];
      return fb == null || fb.toString().contains('like') || fb.toString().contains('bookmark');
    }).toList();

    final top = filtered.length > maxItems ? filtered.sublist(0, maxItems) : filtered;

    return FeedResult(
      items: top,
      totalCount: allItems.length,
      failedSources: _feedSource.lastErrors,
      isEmpty: top.isEmpty,
    );
  }
}
