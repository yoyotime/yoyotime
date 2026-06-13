import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/content.dart';

class StorageService {
  static const _prefsKey = 'yoyotime_prefs_v1';
  static const _feedbackKey = 'yoyotime_feedback_v1';
  static const _userIdKey = 'yoyotime_user_id';
  static const _contentsFile = 'cached_contents.json';
  static const _maxCachedContents = 200;

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<String> getOrCreateUserId() async {
    await init();
    var id = _prefs.getString(_userIdKey);
    if (id == null) {
      id = 'local-${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_userIdKey, id);
    }
    return id;
  }

  Future<UserPreferences> getPreferences() async {
    await init();
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) return const UserPreferences(description: '');
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromJson(json);
    } catch (_) {
      return const UserPreferences(description: '');
    }
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await init();
    await _prefs.setString(_prefsKey, jsonEncode(prefs.toJson()));
  }

  Future<Map<String, FeedbackAction>> getAllFeedback() async {
    await init();
    final raw = _prefs.getString(_feedbackKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map(
        (k, v) => MapEntry(k, FeedbackAction.values[(v as int)]),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> setFeedback(String contentId, FeedbackAction? action) async {
    await init();
    final all = await getAllFeedback();
    if (action == null) {
      all.remove(contentId);
    } else {
      all[contentId] = action;
    }
    await _prefs.setString(
      _feedbackKey,
      jsonEncode(all.map((k, v) => MapEntry(k, v.index))),
    );
  }

  Future<List<ContentItem>> getCachedContents() async {
    try {
      final file = await _getContentsFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedContents(List<ContentItem> items) async {
    try {
      final file = await _getContentsFile();
      final trimmed = items.take(_maxCachedContents).toList();
      final json = jsonEncode(trimmed.map((e) => e.toJson()).toList());
      await file.writeAsString(json);
    } catch (_) {}
  }

  Future<File> _getContentsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _contentsFile));
  }
}

extension on ContentItem {
  Map<String, dynamic> toJson() => {
        'content_id': id,
        'title': title,
        'summary': summary,
        'full_text': fullText,
        'source': {'name': sourceName, 'url': sourceUrl, 'type': 'rss'},
        'media': const [],
        'topics': topics,
        'published_at': publishedAt.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'estimated_read_time_minutes': estimatedReadTimeMinutes,
      };
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
