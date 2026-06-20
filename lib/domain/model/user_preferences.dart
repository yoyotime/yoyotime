import 'app_theme_mode.dart';

class UserPreferences {
  final String description;
  final List<String> _interests;
  final List<String> _blocklist;
  final bool preferAudio;
  final double ttsSpeed;
  final AppThemeMode themeMode;
  final bool dailyReminder;
  final int reminderHour;

  UserPreferences({
    required this.description,
    List<String> interests = const [],
    List<String> blocklist = const [],
    this.preferAudio = false,
    this.ttsSpeed = 1.0,
    this.themeMode = AppThemeMode.system,
    this.dailyReminder = false,
    this.reminderHour = 9,
  })  : _interests = List.unmodifiable(interests),
        _blocklist = List.unmodifiable(blocklist);

  List<String> get interests => _interests;
  List<String> get blocklist => _blocklist;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        description: json['description'] as String? ?? '',
        interests: List<String>.from(json['interests'] ?? []),
        blocklist: List<String>.from(json['blocklist'] ?? []),
        preferAudio: json['prefer_audio'] as bool? ?? false,
        ttsSpeed: (json['tts_speed'] as num?)?.toDouble() ?? 1.0,
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == json['theme_mode'],
          orElse: () => AppThemeMode.system,
        ),
        dailyReminder: json['daily_reminder'] as bool? ?? false,
        reminderHour: json['reminder_hour'] as int? ?? 9,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'interests': _interests,
        'blocklist': _blocklist,
        'prefer_audio': preferAudio,
        'tts_speed': ttsSpeed,
        'theme_mode': themeMode.name,
        'daily_reminder': dailyReminder,
        'reminder_hour': reminderHour,
      };

  UserPreferences copyWith({
    String? description,
    List<String>? interests,
    List<String>? blocklist,
    bool? preferAudio,
    double? ttsSpeed,
    AppThemeMode? themeMode,
    bool? dailyReminder,
    int? reminderHour,
  }) =>
      UserPreferences(
        description: description ?? this.description,
        interests: interests ?? _interests,
        blocklist: blocklist ?? _blocklist,
        preferAudio: preferAudio ?? this.preferAudio,
        ttsSpeed: ttsSpeed ?? this.ttsSpeed,
        themeMode: themeMode ?? this.themeMode,
        dailyReminder: dailyReminder ?? this.dailyReminder,
        reminderHour: reminderHour ?? this.reminderHour,
      );

  bool isBlocked(String title, String summary, List<String> topics) {
    return _blocklist.any((word) =>
        title.contains(word) ||
        summary.contains(word) ||
        topics.any((t) => t.contains(word)));
  }

  UserPreferences addBlocklist(String word) {
    if (word.length < 2) {
      throw ArgumentError('屏蔽词至少2个字');
    }
    if (_blocklist.contains(word)) return this;
    return copyWith(blocklist: [..._blocklist, word]);
  }

  UserPreferences removeBlocklist(String word) {
    return copyWith(blocklist: _blocklist.where((w) => w != word).toList());
  }

  UserPreferences addInterest(String topic) {
    if (_interests.contains(topic)) return this;
    return copyWith(interests: [..._interests, topic]);
  }

  UserPreferences removeInterest(String topic) {
    return copyWith(interests: _interests.where((t) => t != topic).toList());
  }
}
