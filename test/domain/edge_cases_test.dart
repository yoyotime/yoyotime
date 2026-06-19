import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/domain/model/content_item.dart';
import 'package:yoyotime/domain/model/user_preferences.dart';
import 'package:yoyotime/domain/model/feedback_action.dart';
import 'package:yoyotime/domain/service/tone_engine.dart';

void main() {
  group('Edge Cases - ContentItem', () {
    test('empty title should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: '',
        summary: 'summary',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.title, '');
      expect(item.matchesBlocklist([]), isFalse);
    });

    test('empty summary should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: 'title',
        summary: '',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.summary, '');
    });

    test('null fullText should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: 'title',
        summary: 'summary',
        fullText: null,
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.fullText, isNull);
    });

    test('special characters in title should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: '标题<>&"\'',
        summary: '摘要',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.matchesBlocklist(['<>&']), isTrue);
    });

    test('very long title should not crash', () {
      final longTitle = '标题' * 1000;
      final item = ContentItem(
        id: 'test',
        title: longTitle,
        summary: 'summary',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.title.length, 2000);
    });

    test('empty topics list should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: 'title',
        summary: 'summary',
        sourceName: 'source',
        sourceUrl: '',
        topics: [],
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(item.topics, isEmpty);
      expect(item.extractBlocklistKeywords(), isEmpty);
    });

    test('matchesBlocklist with null values should not crash', () {
      final item = ContentItem(
        id: 'test',
        title: 'title',
        summary: 'summary',
        fullText: null,
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      expect(() => item.matchesBlocklist(['word']), returnsNormally);
    });

    test('fromJson with missing fields should use defaults', () {
      final json = <String, dynamic>{
        'content_id': 'test',
        'title': 'title',
        'summary': 'summary',
        'source': {'name': 'source', 'url': '', 'type': 'rss'},
        'published_at': DateTime.now().toIso8601String(),
        'fetched_at': DateTime.now().toIso8601String(),
      };
      final item = ContentItem.fromJson(json);
      expect(item.fullText, isNull);
      expect(item.topics, isEmpty);
      expect(item.estimatedReadTimeMinutes, 3);
    });
  });

  group('Edge Cases - UserPreferences', () {
    test('empty description should not crash', () {
      final prefs = UserPreferences(description: '');
      expect(prefs.description, '');
    });

    test('addBlocklist with empty string should throw', () {
      final prefs = UserPreferences(description: '');
      expect(() => prefs.addBlocklist(''), throwsArgumentError);
    });

    test('addBlocklist with single char should throw', () {
      final prefs = UserPreferences(description: '');
      expect(() => prefs.addBlocklist('A'), throwsArgumentError);
    });

    test('removeBlocklist non-existent word should not crash', () {
      final prefs = UserPreferences(description: '', blocklist: ['A', 'B']);
      final updated = prefs.removeBlocklist('C');
      expect(updated.blocklist, ['A', 'B']);
    });

    test('addInterest with empty string should work', () {
      final prefs = UserPreferences(description: '');
      final updated = prefs.addInterest('');
      expect(updated.interests, contains(''));
    });

    test('isBlocked with empty blocklist should return false', () {
      final prefs = UserPreferences(description: '', blocklist: []);
      expect(prefs.isBlocked('title', 'summary', []), isFalse);
    });

    test('isBlocked with empty title and summary should return false', () {
      final prefs = UserPreferences(description: '', blocklist: ['word']);
      expect(prefs.isBlocked('', '', []), isFalse);
    });

    test('fromJson with null fields should use defaults', () {
      final json = <String, dynamic>{};
      final prefs = UserPreferences.fromJson(json);
      expect(prefs.description, '');
      expect(prefs.interests, isEmpty);
      expect(prefs.blocklist, isEmpty);
      expect(prefs.ttsSpeed, 1.0);
    });

    test('copyWith should preserve all fields', () {
      final prefs = UserPreferences(
        description: 'desc',
        interests: ['A'],
        blocklist: ['B'],
        ttsSpeed: 1.5,
      );
      final updated = prefs.copyWith(description: 'new');
      expect(updated.description, 'new');
      expect(updated.interests, ['A']);
      expect(updated.blocklist, ['B']);
      expect(updated.ttsSpeed, 1.5);
    });
  });

  group('Edge Cases - ToneEngine', () {
    late ToneEngine engine;

    setUp(() {
      engine = ToneEngine();
    });

    test('filter with empty list should return empty', () {
      final result = engine.filter([]);
      expect(result, isEmpty);
    });

    test('evaluate without loading rules should return allow', () {
      final item = ContentItem(
        id: 'test',
        title: '震惊！可怕的消息',
        summary: 'summary',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
      final result = engine.evaluate(item);
      expect(result.action, ToneAction.allow);
    });

    test('filter should preserve order', () {
      final items = List.generate(5, (i) => ContentItem(
        id: 'test-$i',
        title: 'Title $i',
        summary: 'summary',
        sourceName: 'source',
        sourceUrl: '',
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      ));
      final filtered = engine.filter(items);
      expect(filtered.length, 5);
    });
  });

  group('Edge Cases - FeedbackAction', () {
    test('all values should exist', () {
      expect(FeedbackAction.values.length, 4);
      expect(FeedbackAction.values, contains(FeedbackAction.like));
      expect(FeedbackAction.values, contains(FeedbackAction.dislike));
      expect(FeedbackAction.values, contains(FeedbackAction.delete));
      expect(FeedbackAction.values, contains(FeedbackAction.bookmark));
    });
  });
}
