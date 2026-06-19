import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../event/event_bus_provider.dart';
import '../event/events.dart';

final eventHandlerProvider = Provider<EventHandlerService>((ref) {
  final service = EventHandlerService(ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

class EventHandlerService {
  final Ref _ref;
  EventHandlerService(this._ref);

  void init() {
    final bus = _ref.read(eventBusProvider);

    bus.subscribe<ContentFetchedEvent>(_onContentFetched);
    bus.subscribe<ContentDisplayedEvent>(_onContentDisplayed);
    bus.subscribe<FeedbackGivenEvent>(_onFeedbackGiven);
    bus.subscribe<BlocklistUpdatedEvent>(_onBlocklistUpdated);
    bus.subscribe<DailyLimitReachedEvent>(_onDailyLimitReached);
    bus.subscribe<TtsPlaybackStartedEvent>(_onTtsStarted);
    bus.subscribe<TtsPlaybackStoppedEvent>(_onTtsStopped);
    bus.subscribe<ThemeChangedEvent>(_onThemeChanged);
  }

  void dispose() {
    _ref.read(eventBusProvider).clear();
  }

  Future<void> _onContentFetched(ContentFetchedEvent event) async {
    // 可扩展：上报统计、日志记录
  }

  Future<void> _onContentDisplayed(ContentDisplayedEvent event) async {
    // 可扩展：阅读记录、推荐算法反馈
  }

  Future<void> _onFeedbackGiven(FeedbackGivenEvent event) async {
    // 可扩展：用户行为分析、内容质量评估
  }

  Future<void> _onBlocklistUpdated(BlocklistUpdatedEvent event) async {
    // 可扩展：偏好学习、过滤规则优化
  }

  Future<void> _onDailyLimitReached(DailyLimitReachedEvent event) async {
    // 可扩展：提醒通知、使用报告
  }

  Future<void> _onTtsStarted(TtsPlaybackStartedEvent event) async {
    // 可扩展：播放统计
  }

  Future<void> _onTtsStopped(TtsPlaybackStoppedEvent event) async {
    // 可扩展：播放时长统计
  }

  Future<void> _onThemeChanged(ThemeChangedEvent event) async {
    // 可扩展：主题使用统计
  }
}
