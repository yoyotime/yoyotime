import 'package:flutter_test/flutter_test.dart';
import 'package:yoyotime/domain/model/user_preferences.dart';
import 'package:yoyotime/domain/model/app_theme_mode.dart';

void main() {
  group('UserPreferences', () {
    group('addBlocklist', () {
      test('adds word to blocklist', () {
        final prefs = UserPreferences(description: '');
        final updated = prefs.addBlocklist('暴跌');
        expect(updated.blocklist, contains('暴跌'));
      });

      test('does not add duplicate word', () {
        final prefs = UserPreferences(description: '', blocklist: ['暴跌']);
        final updated = prefs.addBlocklist('暴跌');
        expect(updated.blocklist.where((w) => w == '暴跌').length, 1);
      });

      test('throws for single char word', () {
        final prefs = UserPreferences(description: '');
        expect(() => prefs.addBlocklist('A'), throwsArgumentError);
      });

      test('adds two-char word', () {
        final prefs = UserPreferences(description: '');
        final updated = prefs.addBlocklist('AB');
        expect(updated.blocklist, contains('AB'));
      });
    });

    group('removeBlocklist', () {
      test('removes word from blocklist', () {
        final prefs = UserPreferences(description: '', blocklist: ['暴跌', '秘密']);
        final updated = prefs.removeBlocklist('暴跌');
        expect(updated.blocklist, isNot(contains('暴跌')));
        expect(updated.blocklist, contains('秘密'));
      });
    });

    group('addInterest', () {
      test('adds topic to interests', () {
        final prefs = UserPreferences(description: '');
        final updated = prefs.addInterest('财经');
        expect(updated.interests, contains('财经'));
      });

      test('does not add duplicate interest', () {
        final prefs = UserPreferences(description: '', interests: ['财经']);
        final updated = prefs.addInterest('财经');
        expect(updated.interests.where((t) => t == '财经').length, 1);
      });
    });

    group('removeInterest', () {
      test('removes topic from interests', () {
        final prefs = UserPreferences(description: '', interests: ['财经', '国际']);
        final updated = prefs.removeInterest('财经');
        expect(updated.interests, isNot(contains('财经')));
        expect(updated.interests, contains('国际'));
      });
    });

    group('isBlocked', () {
      test('returns true when title matches', () {
        final prefs = UserPreferences(description: '', blocklist: ['暴跌']);
        expect(prefs.isBlocked('今日股市暴跌', '', []), isTrue);
      });

      test('returns true when summary matches', () {
        final prefs = UserPreferences(description: '', blocklist: ['秘密']);
        expect(prefs.isBlocked('', '这个秘密很重要', []), isTrue);
      });

      test('returns true when topic matches', () {
        final prefs = UserPreferences(description: '', blocklist: ['财经']);
        expect(prefs.isBlocked('', '', ['财经', '国际']), isTrue);
      });

      test('returns false when nothing matches', () {
        final prefs = UserPreferences(description: '', blocklist: ['暴跌']);
        expect(prefs.isBlocked('今日天气', '晴朗', ['生活']), isFalse);
      });
    });

    group('copyWith', () {
      test('preserves existing values', () {
        final prefs = UserPreferences(
          description: '测试',
          interests: ['财经'],
          blocklist: ['暴跌'],
          ttsSpeed: 1.5,
          themeMode: AppThemeMode.dark,
        );
        final updated = prefs.copyWith(description: '新描述');
        expect(updated.description, '新描述');
        expect(updated.interests, ['财经']);
        expect(updated.blocklist, ['暴跌']);
        expect(updated.ttsSpeed, 1.5);
        expect(updated.themeMode, AppThemeMode.dark);
      });
    });

    group('toJson / fromJson', () {
      test('roundtrip preserves data', () {
        final prefs = UserPreferences(
          description: '测试兴趣',
          interests: ['财经', '国际'],
          blocklist: ['暴跌', '秘密'],
          preferAudio: true,
          ttsSpeed: 1.5,
          themeMode: AppThemeMode.reading,
        );
        final json = prefs.toJson();
        final restored = UserPreferences.fromJson(json);

        expect(restored.description, prefs.description);
        expect(restored.interests, prefs.interests);
        expect(restored.blocklist, prefs.blocklist);
        expect(restored.preferAudio, prefs.preferAudio);
        expect(restored.ttsSpeed, prefs.ttsSpeed);
        expect(restored.themeMode, prefs.themeMode);
      });
    });
  });
}
