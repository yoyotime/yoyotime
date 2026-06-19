import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/shared/utils/html_utils.dart';

void main() {
  group('HTML Utils - Edge Cases', () {
    test('empty string should return empty', () {
      expect(stripHtml(''), '');
    });

    test('null-like content should not crash', () {
      expect(stripHtml('null'), 'null');
    });

    test('plain text without HTML should pass through', () {
      expect(stripHtml('Hello World'), 'Hello World');
    });

    test('multiple nested tags should be stripped', () {
      expect(stripHtml('<div><p><b>Bold</b></p></div>'), 'Bold');
    });

    test('HTML entities should be decoded', () {
      expect(stripHtml('&amp;'), '&');
      expect(stripHtml('&lt;'), '<');
      expect(stripHtml('&gt;'), '>');
      expect(stripHtml('&quot;'), '"');
      expect(stripHtml('&#39;'), "'");
      expect(stripHtml('&nbsp;'), ' ');
    });

    test('br tags should become newlines', () {
      expect(stripHtml('Line 1<br>Line 2'), 'Line 1\nLine 2');
      expect(stripHtml('Line 1<br/>Line 2'), 'Line 1\nLine 2');
      expect(stripHtml('Line 1<br />Line 2'), 'Line 1\nLine 2');
    });

    test('p tags should become newlines', () {
      expect(stripHtml('<p>Para 1</p><p>Para 2</p>'), 'Para 1\nPara 2');
    });

    test('multiple newlines should be collapsed', () {
      expect(stripHtml('a\n\n\n\n\nb'), 'a\n\nb');
    });

    test('very long HTML should not crash', () {
      final longHtml = '<p>${'text ' * 10000}</p>';
      expect(() => stripHtml(longHtml), returnsNormally);
    });

    test('malformed HTML should be handled gracefully', () {
      expect(stripHtml('<p>unclosed'), 'unclosed');
      expect(stripHtml('random < > tags'), 'random < > tags');
    });

    test('script tags should be stripped', () {
      expect(stripHtml('<script>alert("xss")</script>Safe'), 'Safe');
    });

    test('style tags should be stripped', () {
      expect(stripHtml('<style>.red{color:red}</style>Text'), 'Text');
    });
  });
}
