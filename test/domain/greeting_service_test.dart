import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/domain/service/greeting_service.dart';
import 'package:yoyotime/domain/model/greeting.dart';

void main() {
  group('GreetingService', () {
    late GreetingService service;

    setUp(() {
      service = GreetingService();
    });

    group('generate', () {
      test('returns dawn greeting for 5:00-7:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 6, 30));
        expect(greeting.period, GreetingPeriod.dawn);
        expect(greeting.text.isNotEmpty, isTrue);
        expect(greeting.subText.isNotEmpty, isTrue);
      });

      test('returns morning greeting for 8:00-11:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 9, 0));
        expect(greeting.period, GreetingPeriod.morning);
      });

      test('returns noon greeting for 12:00-13:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 12, 30));
        expect(greeting.period, GreetingPeriod.noon);
      });

      test('returns afternoon greeting for 14:00-17:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 15, 0));
        expect(greeting.period, GreetingPeriod.afternoon);
      });

      test('returns evening greeting for 18:00-20:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 19, 0));
        expect(greeting.period, GreetingPeriod.evening);
      });

      test('returns night greeting for 21:00-23:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 22, 0));
        expect(greeting.period, GreetingPeriod.night);
      });

      test('returns late night greeting for 0:00-4:59', () {
        final greeting = service.generate(now: DateTime(2024, 1, 15, 2, 0));
        expect(greeting.period, GreetingPeriod.lateNight);
      });
    });

    group('holiday greetings', () {
      test('returns new year greeting on Jan 1', () {
        final greeting = service.generate(now: DateTime(2024, 1, 1, 10, 0));
        expect(greeting.subText, contains('新年'));
      });

      test('returns children day greeting on Jun 1', () {
        final greeting = service.generate(now: DateTime(2024, 6, 1, 10, 0));
        expect(greeting.subText, contains('儿童节'));
      });

      test('returns peace day greeting on Sep 21', () {
        final greeting = service.generate(now: DateTime(2024, 9, 21, 10, 0));
        expect(greeting.subText, contains('和平'));
      });
    });

    group('consistency', () {
      test('same hour produces same greeting text', () {
        final g1 = service.generate(now: DateTime(2024, 1, 15, 10, 0));
        final g2 = service.generate(now: DateTime(2024, 1, 15, 10, 30));
        expect(g1.text, g2.text);
      });

      test('different hours can produce different greetings', () {
        final morning = service.generate(now: DateTime(2024, 1, 15, 9, 0));
        final evening = service.generate(now: DateTime(2024, 1, 15, 19, 0));
        expect(morning.period, isNot(evening.period));
      });
    });
  });
}
