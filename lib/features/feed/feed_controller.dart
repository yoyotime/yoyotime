import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/feed/feed_fetcher.dart';
import '../../core/engine/tone_engine.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/event/event_bus_provider.dart';
import '../../domain/event/events.dart';
import '../../shared/models/content.dart';

class FeedState {
  final List<ContentItem> items;
  final bool isLoading;
  final bool isOffline;
  final String? error;
  final DateTime? lastUpdated;
  final List<String> failedSources;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.error,
    this.lastUpdated,
    this.failedSources = const [],
  });

  FeedState copyWith({
    List<ContentItem>? items,
    bool? isLoading,
    bool? isOffline,
    String? error,
    DateTime? lastUpdated,
    List<String>? failedSources,
  }) =>
      FeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isOffline: isOffline ?? this.isOffline,
        error: error,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        failedSources: failedSources ?? this.failedSources,
      );
}

class FeedController extends Notifier<FeedState> {
  late final FeedFetcher _fetcher;
  late final ToneEngine _tone;
  late final StorageService _storage;

  @override
  FeedState build() {
    _fetcher = ref.watch(feedFetcherProvider);
    _tone = ref.watch(toneEngineProvider);
    _storage = ref.watch(storageServiceProvider);
    Future.microtask(() async {
      await _tone.loadRules();
      await load();
    });
    return const FeedState(isLoading: true);
  }

  Future<void> load() => _load(force: false);

  Future<void> refresh() => _load(force: true);

  Future<void> _load({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    final consumed = await _storage.getDailyConsumedCount();
    if (consumed >= 10 && !force) {
      final cached = await _storage.getCachedContents();
      state = state.copyWith(
        items: cached.length > 10 ? cached.sublist(0, 10) : cached,
        isLoading: false,
        error: '今天的内容看完了，明天见',
      );
      ref.read(eventBusProvider).publish(DailyLimitReachedEvent(count: consumed));
      return;
    }

    final cached = await _storage.getCachedContents();
    if (cached.isNotEmpty && !force) {
      state = state.copyWith(items: cached, isLoading: false);
    }

    try {
      final prefs = await _storage.getPreferences();
      final blocklist = prefs.blocklist;
      final feedback = await _storage.getAllFeedback();

      final allItems = await _fetcher.fetchAll();
      var filtered = _tone.filter(allItems);

      filtered = filtered.where((item) {
        final matched = blocklist.any((word) =>
            item.title.contains(word) ||
            item.summary.contains(word) ||
            item.topics.any((t) => t.contains(word)));
        return !matched;
      }).toList();

      filtered = filtered.where((item) {
        final fb = feedback[item.id];
        return fb == null || fb == FeedbackAction.like || fb == FeedbackAction.bookmark;
      }).toList();

      final top = filtered.length > 10 ? filtered.sublist(0, 10) : filtered;

      await _storage.saveCachedContents(top);

      ref.read(eventBusProvider).publish(ContentFetchedEvent(
        totalCount: allItems.length,
        filteredCount: top.length,
        failedSources: _fetcher.lastErrors,
      ));

      if (top.isEmpty && allItems.isEmpty && _fetcher.lastErrors.isNotEmpty) {
        state = state.copyWith(
          items: top,
          isLoading: false,
          isOffline: true,
          error: '暂未获取到内容',
          failedSources: _fetcher.lastErrors,
        );
      } else {
        state = state.copyWith(
          items: top,
          isLoading: false,
          isOffline: false,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      final demo = cached.isNotEmpty ? state.items : _demoContents();
      if (cached.isEmpty) {
        await _storage.saveCachedContents(demo);
      }
      state = state.copyWith(
        items: demo,
        isLoading: false,
        isOffline: true,
        error: cached.isNotEmpty ? null : '暂未获取到内容',
      );
    }
  }

  List<ContentItem> _demoContents() {
    final now = DateTime.now();
    return [
      ContentItem(
        id: 'demo-1',
        title: '联合国报告：全球儿童安全状况持续改善',
        summary: '联合国儿童基金会最新报告显示，过去十年全球儿童死亡率下降近50%，但部分地区仍面临挑战。',
        fullText: '联合国儿童基金会（UNICEF）今日发布年度报告，指出全球儿童生存状况在过去十年取得显著进步。报告显示，5岁以下儿童死亡率较十年前下降了49%，这主要得益于疫苗普及和基础医疗条件的改善。然而，报告也指出，在冲突地区和偏远山区，儿童面临的营养不良、教育和安全保障问题依然严峻。UNICEF呼吁国际社会继续加大对儿童权益的投入，确保每个孩子都能享有安全的成长环境。',
        sourceName: '联合国新闻',
        sourceUrl: '',
        topics: ['儿童安全', '和平', '国际'],
        publishedAt: now.subtract(const Duration(hours: 3)),
        fetchedAt: now,
        estimatedReadTimeMinutes: 4,
      ),
      ContentItem(
        id: 'demo-2',
        title: '气候变化下的海洋保护：新协议达成',
        summary: '190多个国家达成历史性海洋保护协议，将保护30%的公海区域。',
        fullText: '在经过长达五年的谈判后，190多个国家在联合国总部正式签署了公海生物多样性保护协议。该协议旨在到2030年保护全球30%的公海区域，建立海洋保护区网络，并对深海采矿等经济活动进行严格监管。环境专家表示，这是地球保护史上的里程碑时刻，对维护海洋生态平衡和应对气候变化具有重要意义。',
        sourceName: '联合国新闻',
        sourceUrl: '',
        topics: ['环境', '和平', '国际'],
        publishedAt: now.subtract(const Duration(hours: 6)),
        fetchedAt: now,
        estimatedReadTimeMinutes: 3,
      ),
      ContentItem(
        id: 'demo-3',
        title: '老年人防诈骗指南：牢记五个"不"',
        summary: '公安部发布最新防诈骗指南，帮助老年人识别常见骗局。',
        fullText: '公安部刑事侦查局今日发布《老年人防诈骗手册》，总结出五种最常见的诈骗手法：冒充公检法、投资理财陷阱、保健品推销、中奖信息和亲情诈骗。警方提醒市民牢记五个"不"：不轻信陌生来电、不透露个人信息、不转账给陌生人、不点击不明链接、不扫陌生二维码。如遇可疑情况，请立即拨打反诈热线96110。',
        sourceName: '新华社',
        sourceUrl: '',
        topics: ['安全', '社会'],
        publishedAt: now.subtract(const Duration(hours: 8)),
        fetchedAt: now,
        estimatedReadTimeMinutes: 5,
      ),
      ContentItem(
        id: 'demo-4',
        title: '阳台种菜指南：新手也能收获满满',
        summary: '从选种到收获，一站式教你如何在阳台种出新鲜蔬菜。',
        fullText: '越来越多城市居民开始在阳台种植蔬菜，既能吃上新鲜食材，又能享受种植乐趣。本文从选盆、配土、选种、浇水、施肥五个方面详细介绍阳台种菜的要点。推荐新手从韭菜、小葱、生菜、番茄等易成活品种开始尝试。春季是播种的最佳时节，现在开始，两个月后就能收获第一批自己种的蔬菜。',
        sourceName: '少数派',
        sourceUrl: '',
        topics: ['生活', '种菜'],
        publishedAt: now.subtract(const Duration(hours: 12)),
        fetchedAt: now,
        estimatedReadTimeMinutes: 6,
      ),
      ContentItem(
        id: 'demo-5',
        title: '国际和平日：全球多地举行纪念活动',
        summary: '9月21日国际和平日到来之际，世界各地举办多种形式的和平纪念活动。',
        fullText: '今天是国际和平日，联合国总部举行了隆重的纪念仪式。秘书长在致辞中强调，在当前国际局势复杂多变的背景下，维护世界和平与安全比以往任何时候都更加重要。与此同时，全球多个城市举办了和平主题的展览、音乐会和论坛。今年和平日的主题是"和平与包容"，呼吁各国通过对话与合作解决分歧，共同构建一个更加公正、和平的世界。',
        sourceName: '联合国新闻',
        sourceUrl: '',
        topics: ['和平', '国际'],
        publishedAt: now.subtract(const Duration(hours: 14)),
        fetchedAt: now,
        estimatedReadTimeMinutes: 4,
      ),
    ];
  }

  Future<void> actOnContent(ContentItem item, FeedbackAction action) async {
    await _storage.setFeedback(item.id, action);

    ref.read(eventBusProvider).publish(FeedbackGivenEvent(
      contentId: item.id,
      action: action,
    ));

    if (action == FeedbackAction.delete || action == FeedbackAction.dislike) {
      final updated = state.items.where((c) => c.id != item.id).toList();
      state = state.copyWith(items: updated);

      if (action == FeedbackAction.dislike) {
        final prefs = await _storage.getPreferences();
        final words = [...item.topics, ...item.title.split(RegExp(r'[\s,，。、]+'))];
        final newWords = words.where((w) => w.length >= 2 && !prefs.blocklist.contains(w)).toList();

        for (final word in newWords) {
          ref.read(eventBusProvider).publish(BlocklistUpdatedEvent(word: word, added: true));
        }

        final existing = Set<String>.from(prefs.blocklist);
        existing.addAll(newWords);
        await _storage.savePreferences(UserPreferences(
          description: prefs.description,
          interests: prefs.interests,
          blocklist: existing.toList(),
          preferAudio: prefs.preferAudio,
          ttsSpeed: prefs.ttsSpeed,
          themeMode: prefs.themeMode,
        ));
      }
    }
  }
}

final feedControllerProvider =
    NotifierProvider<FeedController, FeedState>(FeedController.new);
