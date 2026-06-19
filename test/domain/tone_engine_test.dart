import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/domain/service/tone_engine.dart';
import 'package:yoyotime/domain/model/content_item.dart';

void main() {
  group('ToneEngine', () {
    late ToneEngine engine;

    setUp(() {
      engine = ToneEngine();
    });

    ContentItem createItem({
      String? title,
      String? summary,
      String? fullText,
      List<String>? topics,
    }) {
      return ContentItem(
        id: 'test-1',
        title: title ?? '测试标题',
        summary: summary ?? '测试摘要',
        fullText: fullText,
        sourceName: '测试源',
        sourceUrl: 'https://example.com',
        topics: topics ?? [],
        publishedAt: DateTime.now(),
        fetchedAt: DateTime.now(),
      );
    }

    group('evaluate', () {
      test('returns allow for neutral content', () {
        final item = createItem(title: '今日天气晴朗');
        final result = engine.evaluate(item);
        expect(result.action, ToneAction.allow);
      });

      test('returns allow when no rules loaded', () {
        final item = createItem(title: '震惊！这个消息太可怕了');
        final result = engine.evaluate(item);
        expect(result.action, ToneAction.allow);
      });
    });

    group('filter', () {
      test('returns all items when no rules loaded', () {
        final items = [
          createItem(title: '标题1'),
          createItem(title: '标题2'),
          createItem(title: '标题3'),
        ];
        final filtered = engine.filter(items);
        expect(filtered.length, 3);
      });

      test('returns empty list for empty input', () {
        final filtered = engine.filter([]);
        expect(filtered, isEmpty);
      });
    });
  });
}
