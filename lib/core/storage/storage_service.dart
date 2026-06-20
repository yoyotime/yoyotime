import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/models.dart';
import '../../domain/repository/content_repository.dart';
import '../../domain/repository/preferences_repository.dart';

class StorageService implements ContentRepository, PreferencesRepository {
  static const _prefsKey = 'yoyotime_prefs_v1';
  static const _feedbackKey = 'yoyotime_feedback_v1';
  static const _userIdKey = 'yoyotime_user_id';
  static const _contentsFile = 'cached_contents.json';
  static const _maxCachedContents = 200;

  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// 初始化存储服务
  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      developer.log('StorageService initialized', name: 'storage');
    } catch (e) {
      developer.log('Failed to initialize StorageService: $e', name: 'storage');
      rethrow;
    }
  }

  /// 获取或创建用户ID
  Future<String> getOrCreateUserId() async {
    await init();
    var id = _prefs.getString(_userIdKey);
    if (id == null) {
      id = 'local-${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(_userIdKey, id);
      developer.log('Created new user ID: $id', name: 'storage');
    }
    return id;
  }

  @override
  Future<UserPreferences> getPreferences() async {
    await init();
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) return UserPreferences(description: '');
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromJson(json);
    } catch (e) {
      developer.log('Failed to parse preferences: $e', name: 'storage');
      return UserPreferences(description: '');
    }
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    await init();
    try {
      await _prefs.setString(_prefsKey, jsonEncode(prefs.toJson()));
      developer.log('Preferences saved', name: 'storage');
    } catch (e) {
      developer.log('Failed to save preferences: $e', name: 'storage');
      rethrow;
    }
  }

  @override
  Future<Map<String, FeedbackAction>> getAllFeedback() async {
    await init();
    final raw = _prefs.getString(_feedbackKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map(
        (k, v) => MapEntry(k, FeedbackAction.values[(v as int)]),
      );
    } catch (e) {
      developer.log('Failed to parse feedback: $e', name: 'storage');
      return {};
    }
  }

  @override
  Future<void> setFeedback(String contentId, FeedbackAction? action) async {
    await init();
    final all = await getAllFeedback();
    if (action == null) {
      all.remove(contentId);
    } else {
      all[contentId] = action;
    }
    try {
      await _prefs.setString(
        _feedbackKey,
        jsonEncode(all.map((k, v) => MapEntry(k, v.index))),
      );
      developer.log('Feedback updated for $contentId: $action', name: 'storage');
    } catch (e) {
      developer.log('Failed to save feedback: $e', name: 'storage');
      rethrow;
    }
  }

  @override
  Future<List<ContentItem>> getCachedContents() async {
    try {
      final file = await _getContentsFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to load cached contents: $e', name: 'storage');
      return [];
    }
  }

  @override
  Future<void> saveCachedContents(List<ContentItem> items) async {
    try {
      final file = await _getContentsFile();
      final trimmed = items.take(_maxCachedContents).toList();
      final json = jsonEncode(trimmed.map((e) => e.toJson()).toList());
      await file.writeAsString(json);
      developer.log('Cached ${trimmed.length} contents', name: 'storage');
    } catch (e) {
      developer.log('Failed to save cached contents: $e', name: 'storage');
    }
  }

  Future<File> _getContentsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _contentsFile));
  }

  @override
  Future<int> getDailyConsumedCount() async {
    await init();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'daily_count_$today';
    return _prefs.getInt(key) ?? 0;
  }

  @override
  Future<void> incrementDailyConsumedCount() async {
    await init();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'daily_count_$today';
    final current = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, current + 1);
    developer.log('Daily count incremented: ${current + 1}', name: 'storage');
  }

  @override
  Future<List<ContentItem>> getBookmarkedContents() async {
    final allFeedback = await getAllFeedback();
    final bookmarkedIds = allFeedback.entries
        .where((e) => e.value == FeedbackAction.bookmark)
        .map((e) => e.key)
        .toList();

    final cached = await getCachedContents();
    return cached.where((item) => bookmarkedIds.contains(item.id)).toList();
  }

  Future<List<String>> getWeeklyReadIds() async {
    await init();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final ids = <String>[];

    for (var i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      final key = 'read_ids_$dateStr';
      final dayIds = _prefs.getStringList(key) ?? [];
      ids.addAll(dayIds);
    }

    return ids.toSet().toList();
  }

  Future<void> trackRead(String contentId) async {
    await init();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'read_ids_$today';
    final ids = _prefs.getStringList(key) ?? [];
    if (!ids.contains(contentId)) {
      ids.add(contentId);
      await _prefs.setStringList(key, ids);
      developer.log('Content read tracked: $contentId', name: 'storage');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
