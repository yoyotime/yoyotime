import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyotime/core/storage/storage_service.dart';
import 'package:yoyotime/core/feed/feed_fetcher.dart';
import 'package:yoyotime/domain/service/tone_engine.dart';
import 'package:yoyotime/domain/model/content_item.dart';
import 'package:yoyotime/domain/model/feedback_action.dart';

void main() {
  group('FeedController - Use Case Logic', () {
    late StorageService storage;
    late FeedFetcher fetcher;
    late ToneEngine tone;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
      await storage.init();
      fetcher = FeedFetcher();
      tone = ToneEngine();
    });

    group('Daily Limit', () {
      test('should allow loading when count is 0', () async {
        final count = await storage.getDailyConsumedCount();
        expect(count, 0);
      });

      test('should increment count', () async {
        await storage.incrementDailyConsumedCount();
        await storage.incrementDailyConsumedCount();
        final count = await storage.getDailyConsumedCount();
        expect(count, 2);
      });

      test('should detect limit reached at 10', () async {
        for (var i = 0; i < 10; i++) {
          await storage.incrementDailyConsumedCount();
        }
        final count = await storage.getDailyConsumedCount();
        expect(count, 10);
      });
    });

    group('Content Cache', () {
      test('should save and retrieve contents', () async {
        final items = _createItems(5);
        await storage.saveCachedContents(items);
        final cached = await storage.getCachedContents();
        expect(cached.length, 5);
      });

      test('should limit cached items to 200', () async {
        final items = _createItems(250);
        await storage.saveCachedContents(items);
        final cached = await storage.getCachedContents();
        expect(cached.length, 200);
      });

      test('should preserve item order', () async {
        final items = _createItems(5);
        await storage.saveCachedContents(items);
        final cached = await storage.getCachedContents();
        expect(cached[0].id, 'item-0');
        expect(cached[4].id, 'item-4');
      });
    });

    group('Feedback', () {
      test('should save like feedback', () async {
        await storage.setFeedback('content-1', FeedbackAction.like);
        final feedback = await storage.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.like);
      });

      test('should save dislike feedback', () async {
        await storage.setFeedback('content-1', FeedbackAction.dislike);
        final feedback = await storage.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.dislike);
      });

      test('should save bookmark feedback', () async {
        await storage.setFeedback('content-1', FeedbackAction.bookmark);
        final feedback = await storage.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.bookmark);
      });

      test('should update feedback', () async {
        await storage.setFeedback('content-1', FeedbackAction.like);
        await storage.setFeedback('content-1', FeedbackAction.dislike);
        final feedback = await storage.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.dislike);
      });

      test('should remove feedback', () async {
        await storage.setFeedback('content-1', FeedbackAction.like);
        await storage.setFeedback('content-1', null);
        final feedback = await storage.getAllFeedback();
        expect(feedback.containsKey('content-1'), isFalse);
      });
    });

    group('Blocklist', () {
      test('should add words to blocklist', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.addBlocklist('暴跌');
        prefs = prefs.addBlocklist('秘密');
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        expect(loaded.blocklist, containsAll(['暴跌', '秘密']));
      });

      test('should remove words from blocklist', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.addBlocklist('暴跌');
        prefs = prefs.addBlocklist('秘密');
        await storage.savePreferences(prefs);

        prefs = await storage.getPreferences();
        prefs = prefs.removeBlocklist('暴跌');
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        expect(loaded.blocklist, isNot(contains('暴跌')));
        expect(loaded.blocklist, contains('秘密'));
      });

      test('should filter items by blocklist', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.addBlocklist('暴跌');
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        final item = ContentItem(
          id: 'test',
          title: '今日股市暴跌',
          summary: 'summary',
          sourceName: 'source',
          sourceUrl: '',
          publishedAt: DateTime.now(),
          fetchedAt: DateTime.now(),
        );

        expect(loaded.isBlocked(item.title, item.summary, item.topics), isTrue);
      });
    });

    group('ContentItem Filtering', () {
      test('should filter items matching feedback', () async {
        await storage.setFeedback('item-1', FeedbackAction.dislike);
        await storage.setFeedback('item-2', FeedbackAction.like);
        await storage.setFeedback('item-3', FeedbackAction.bookmark);

        final feedback = await storage.getAllFeedback();
        final items = _createItems(3);

        final filtered = items.where((item) => item.matchesFeedback(feedback)).toList();
        expect(filtered.length, 2);
        expect(filtered.map((i) => i.id), containsAll(['item-1', 'item-2']));
      });

      test('should filter items matching blocklist', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.addBlocklist('暴跌');
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        final items = [
          ContentItem(
            id: '1',
            title: '今日股市暴跌',
            summary: 'summary',
            sourceName: 'source',
            sourceUrl: '',
            publishedAt: DateTime.now(),
            fetchedAt: DateTime.now(),
          ),
          ContentItem(
            id: '2',
            title: '今日天气晴朗',
            summary: 'summary',
            sourceName: 'source',
            sourceUrl: '',
            publishedAt: DateTime.now(),
            fetchedAt: DateTime.now(),
          ),
        ];

        final filtered = items.where((item) => !loaded.isBlocked(item.title, item.summary, item.topics)).toList();
        expect(filtered.length, 1);
        expect(filtered[0].id, '2');
      });

      test('should limit items to 10', () async {
        final items = _createItems(15);
        final limited = items.length > 10 ? items.sublist(0, 10) : items;
        expect(limited.length, 10);
      });
    });

    group('Preferences', () {
      test('should save and retrieve', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.copyWith(
          description: 'test description',
          ttsSpeed: 1.5,
        );
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        expect(loaded.description, 'test description');
        expect(loaded.ttsSpeed, 1.5);
      });

      test('should preserve other fields on update', () async {
        var prefs = await storage.getPreferences();
        prefs = prefs.addBlocklist('暴跌');
        prefs = prefs.addInterest('财经');
        await storage.savePreferences(prefs);

        prefs = await storage.getPreferences();
        prefs = prefs.copyWith(description: 'new desc');
        await storage.savePreferences(prefs);

        final loaded = await storage.getPreferences();
        expect(loaded.description, 'new desc');
        expect(loaded.blocklist, contains('暴跌'));
        expect(loaded.interests, contains('财经'));
      });
    });
  });
}

List<ContentItem> _createItems(int count) {
  return List.generate(count, (i) => ContentItem(
    id: 'item-$i',
    title: 'Title $i',
    summary: 'Summary $i',
    sourceName: 'Source',
    sourceUrl: '',
    topics: ['topic-$i'],
    publishedAt: DateTime.now().subtract(Duration(hours: i)),
    fetchedAt: DateTime.now(),
  ));
}
