import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyotime/core/storage/storage_service.dart';
import 'package:yoyotime/domain/model/content_item.dart';
import 'package:yoyotime/domain/model/feedback_action.dart';

void main() {
  group('StorageService - Edge Cases', () {
    late StorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = StorageService();
      await service.init();
    });

    group('getCachedContents', () {
      test('should return empty list when no cache exists', () async {
        final contents = await service.getCachedContents();
        expect(contents, isEmpty);
      });
    });

    group('saveCachedContents', () {
      test('should handle empty list', () async {
        await service.saveCachedContents([]);
        final contents = await service.getCachedContents();
        expect(contents, isEmpty);
      });

      test('should limit to 200 items', () async {
        final items = List.generate(250, (i) => ContentItem(
          id: 'item-$i',
          title: 'Title $i',
          summary: 'Summary $i',
          sourceName: 'Source',
          sourceUrl: '',
          publishedAt: DateTime.now(),
          fetchedAt: DateTime.now(),
        ));
        await service.saveCachedContents(items);
        final contents = await service.getCachedContents();
        expect(contents.length, 200);
      });
    });

    group('getPreferences', () {
      test('should return default when no prefs saved', () async {
        final prefs = await service.getPreferences();
        expect(prefs.description, '');
        expect(prefs.interests, isEmpty);
        expect(prefs.blocklist, isEmpty);
      });
    });

    group('savePreferences', () {
      test('should persist and retrieve', () async {
        final prefs = await service.getPreferences();
        final updated = prefs.copyWith(description: 'test');
        await service.savePreferences(updated);
        final loaded = await service.getPreferences();
        expect(loaded.description, 'test');
      });
    });

    group('getAllFeedback', () {
      test('should return empty when no feedback', () async {
        final feedback = await service.getAllFeedback();
        expect(feedback, isEmpty);
      });
    });

    group('setFeedback', () {
      test('should save feedback', () async {
        await service.setFeedback('content-1', FeedbackAction.like);
        final feedback = await service.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.like);
      });

      test('should remove feedback when null', () async {
        await service.setFeedback('content-1', FeedbackAction.like);
        await service.setFeedback('content-1', null);
        final feedback = await service.getAllFeedback();
        expect(feedback.containsKey('content-1'), isFalse);
      });

      test('should update existing feedback', () async {
        await service.setFeedback('content-1', FeedbackAction.like);
        await service.setFeedback('content-1', FeedbackAction.dislike);
        final feedback = await service.getAllFeedback();
        expect(feedback['content-1'], FeedbackAction.dislike);
      });
    });

    group('getDailyConsumedCount', () {
      test('should return 0 when no count', () async {
        final count = await service.getDailyConsumedCount();
        expect(count, 0);
      });
    });

    group('incrementDailyConsumedCount', () {
      test('should increment', () async {
        await service.incrementDailyConsumedCount();
        await service.incrementDailyConsumedCount();
        final count = await service.getDailyConsumedCount();
        expect(count, 2);
      });
    });

    group('getBookmarkedContents', () {
      test('should return empty when no bookmarks', () async {
        final bookmarks = await service.getBookmarkedContents();
        expect(bookmarks, isEmpty);
      });
    });

    group('getWeeklyReadIds', () {
      test('should return empty when no reads', () async {
        final ids = await service.getWeeklyReadIds();
        expect(ids, isEmpty);
      });
    });

    group('trackRead', () {
      test('should track read', () async {
        await service.trackRead('content-1');
        await service.trackRead('content-1'); // duplicate
        final ids = await service.getWeeklyReadIds();
        expect(ids.length, 1);
        expect(ids, contains('content-1'));
      });
    });

    group('getOrCreateUserId', () {
      test('should create user id', () async {
        final id = await service.getOrCreateUserId();
        expect(id.startsWith('local-'), isTrue);
      });

      test('should return same id on subsequent calls', () async {
        final id1 = await service.getOrCreateUserId();
        final id2 = await service.getOrCreateUserId();
        expect(id1, id2);
      });
    });
  });
}
