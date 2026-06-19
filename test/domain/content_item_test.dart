import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/domain/model/content_item.dart';
import 'package:yoyotime/domain/model/content_media.dart';
import 'package:yoyotime/domain/model/feedback_action.dart';

void main() {
  group('ContentItem', () {
    ContentItem createItem({
      String? title,
      String? summary,
      List<String>? topics,
    }) {
      return ContentItem(
        id: 'test-1',
        title: title ?? '测试标题',
        summary: summary ?? '测试摘要',
        sourceName: '测试源',
        sourceUrl: 'https://example.com',
        topics: topics ?? ['测试'],
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
    }

    group('matchesBlocklist', () {
      test('returns true when title contains blocked word', () {
        final item = createItem(title: '今日股市暴跌');
        expect(item.matchesBlocklist(['暴跌']), isTrue);
      });

      test('returns true when summary contains blocked word', () {
        final item = createItem(summary: '震惊！这个秘密被揭露了');
        expect(item.matchesBlocklist(['秘密']), isTrue);
      });

      test('returns true when topic contains blocked word', () {
        final item = createItem(topics: ['财经', '股市']);
        expect(item.matchesBlocklist(['财经']), isTrue);
      });

      test('returns false when no blocked words match', () {
        final item = createItem(title: '今日天气晴朗');
        expect(item.matchesBlocklist(['暴跌', '秘密']), isFalse);
      });

      test('returns false for empty blocklist', () {
        final item = createItem(title: '今日新闻');
        expect(item.matchesBlocklist([]), isFalse);
      });
    });

    group('matchesFeedback', () {
      test('returns true when no feedback exists', () {
        final item = createItem();
        expect(item.matchesFeedback({}), isTrue);
      });

      test('returns true when feedback is like', () {
        final item = createItem();
        expect(item.matchesFeedback({'test-1': FeedbackAction.like}), isTrue);
      });

      test('returns true when feedback is bookmark', () {
        final item = createItem();
        expect(item.matchesFeedback({'test-1': FeedbackAction.bookmark}), isTrue);
      });

      test('returns false when feedback is dislike', () {
        final item = createItem();
        expect(item.matchesFeedback({'test-1': FeedbackAction.dislike}), isFalse);
      });

      test('returns false when feedback is delete', () {
        final item = createItem();
        expect(item.matchesFeedback({'test-1': FeedbackAction.delete}), isFalse);
      });
    });

    group('extractBlocklistKeywords', () {
      test('extracts topics as keywords', () {
        final item = createItem(topics: ['财经', '股市']);
        final keywords = item.extractBlocklistKeywords();
        expect(keywords, containsAll(['财经', '股市']));
      });

      test('extracts title words longer than 1 char', () {
        final item = createItem(title: '今日 股市 暴跌');
        final keywords = item.extractBlocklistKeywords();
        expect(keywords, containsAll(['今日', '股市', '暴跌']));
      });

      test('filters out single char words', () {
        final item = createItem(title: 'A 今日 B');
        final keywords = item.extractBlocklistKeywords();
        expect(keywords, isNot(contains('A')));
        expect(keywords, isNot(contains('B')));
        expect(keywords, contains('今日'));
      });
    });

    group('toJson / fromJson', () {
      test('roundtrip preserves data', () {
        final item = createItem(
          title: '测试标题',
          summary: '测试摘要',
          topics: ['财经', '国际'],
        );
        final json = item.toJson();
        final restored = ContentItem.fromJson(json);

        expect(restored.id, item.id);
        expect(restored.title, item.title);
        expect(restored.summary, item.summary);
        expect(restored.sourceName, item.sourceName);
        expect(restored.topics, item.topics);
      });
    });
  });
}
