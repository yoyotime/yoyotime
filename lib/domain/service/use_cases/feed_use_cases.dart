import '../../model/content_item.dart';
import '../../model/feedback_action.dart';
import '../../repository/content_repository.dart';
import '../../repository/preferences_repository.dart';
import '../../event/event_bus.dart';
import '../../event/events.dart';

/// 缓存内容用例
/// 将获取的内容保存到本地缓存
class CacheFeedUseCase {
  final ContentRepository _contentRepo;

  CacheFeedUseCase(this._contentRepo);

  /// 执行缓存操作
  /// [items] 要缓存的内容列表
  Future<void> execute(List<ContentItem> items) async {
    await _contentRepo.saveCachedContents(items);
  }
}

/// 加载缓存内容用例
/// 从本地缓存加载内容
class LoadCachedFeedUseCase {
  final ContentRepository _contentRepo;

  LoadCachedFeedUseCase(this._contentRepo);

  /// 执行加载操作
  /// 返回缓存的内容列表
  Future<List<ContentItem>> execute() async {
    return await _contentRepo.getCachedContents();
  }
}

/// 每日限制用例
/// 检查和管理每日阅读限制
class EnforceDailyLimitUseCase {
  final PreferencesRepository _prefsRepo;
  final int dailyLimit;

  EnforceDailyLimitUseCase(this._prefsRepo, {this.dailyLimit = 10});

  /// 检查是否达到每日限制
  /// 返回true表示已达到限制
  Future<bool> isLimitReached() async {
    final consumed = await _prefsRepo.getDailyConsumedCount();
    return consumed >= dailyLimit;
  }

  /// 获取已消费数量
  Future<int> getConsumedCount() async {
    return await _prefsRepo.getDailyConsumedCount();
  }

  /// 获取剩余可消费数量
  Future<int> getRemainingCount() async {
    final consumed = await _prefsRepo.getDailyConsumedCount();
    return (dailyLimit - consumed).clamp(0, dailyLimit);
  }
}

/// 内容操作用例
/// 处理用户对内容的操作（点赞、不喜欢、收藏等）
class ActOnContentUseCase {
  final ContentRepository _contentRepo;
  final PreferencesRepository _prefsRepo;
  final EventBus _eventBus;

  ActOnContentUseCase(this._contentRepo, this._prefsRepo, this._eventBus);

  /// 执行内容操作
  /// [item] 要操作的内容
  /// [action] 操作类型
  Future<void> execute(ContentItem item, FeedbackAction action) async {
    // 保存用户反馈
    await _contentRepo.setFeedback(item.id, action);

    // 发布反馈事件
    _eventBus.publish(FeedbackGivenEvent(
      contentId: item.id,
      action: action,
    ));

    // 如果是不喜欢操作，自动添加屏蔽词
    if (action == FeedbackAction.dislike) {
      await _autoAddBlocklist(item);
    }
  }

  /// 自动添加屏蔽词
  /// 从内容中提取关键词并添加到屏蔽列表
  Future<void> _autoAddBlocklist(ContentItem item) async {
    final prefs = await _prefsRepo.getPreferences();
    final newWords = item.extractBlocklistKeywords()
        .where((w) => !prefs.blocklist.contains(w))
        .toList();

    // 发布屏蔽词更新事件
    for (final word in newWords) {
      _eventBus.publish(BlocklistUpdatedEvent(word: word, added: true));
    }

    // 更新用户偏好
    var updatedPrefs = prefs;
    for (final word in newWords) {
      updatedPrefs = updatedPrefs.addBlocklist(word);
    }
    await _prefsRepo.savePreferences(updatedPrefs);
  }
}
