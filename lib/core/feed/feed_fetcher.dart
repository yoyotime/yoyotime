import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webfeed/webfeed.dart';
import '../../shared/models/content.dart';

class FeedSource {
  final String id;
  final String name;
  final String url;
  final String type;
  final String category;
  final List<String> topics;
  final bool enabled;
  final int updateIntervalMinutes;

  const FeedSource({
    required this.id,
    required this.name,
    required this.url,
    this.type = 'rss',
    required this.category,
    this.topics = const [],
    this.enabled = true,
    this.updateIntervalMinutes = 60,
  });

  factory FeedSource.fromJson(Map<String, dynamic> json) => FeedSource(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        type: json['type'] as String? ?? 'rss',
        category: json['category'] as String,
        topics: List<String>.from(json['topics'] ?? []),
        enabled: json['enabled'] as bool? ?? true,
        updateIntervalMinutes: json['updateIntervalMinutes'] as int? ?? 60,
      );
}

class FeedFetcher {
  late final Dio _dio;
  List<FeedSource> _sources = [];
  List<String> lastErrors = [];

  FeedFetcher({Dio? dio}) {
    _dio = dio ?? Dio(BaseOptions(
      headers: {
        'User-Agent': 'Yoyotime/0.4.0',
        'Accept': 'application/rss+xml, application/xml, text/xml, application/json, */*',
      },
    ));
  }

  Future<List<FeedSource>> loadSources() async {
    final raw = await rootBundle.loadString('assets/config/sources.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['sources'] as List<dynamic>;
    _sources = list
        .map((e) => FeedSource.fromJson(e as Map<String, dynamic>))
        .where((s) => s.enabled)
        .toList();
    return _sources;
  }

  Future<List<ContentItem>> fetchAll() async {
    if (_sources.isEmpty) await loadSources();

    lastErrors = [];
    final results = await Future.wait(
      _sources.map((s) => _fetchSource(s)),
      eagerError: false,
    );

    final items = <ContentItem>[];
    for (var i = 0; i < results.length; i++) {
      if (results[i].isEmpty) {
        lastErrors.add(_sources[i].name);
      }
      items.addAll(results[i]);
    }

    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items;
  }

  Future<List<ContentItem>> _fetchSource(FeedSource source) async {
    try {
      if (source.type == 'jsonfeed') {
        return _fetchJsonFeed(source);
      }

      final res = await _dio.get<String>(
        source.url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final xml = res.data;
      if (xml == null || xml.isEmpty) return [];

      final now = DateTime.now();
      final items = <ContentItem>[];

      try {
        final rss = RssFeed.parse(xml);
        if (rss.items != null) {
          for (final item in rss.items!) {
            if (item == null) continue;
            final parsed = _fromRssItem(item, source, now);
            if (parsed != null) items.add(parsed);
          }
        }
        return items;
      } catch (_) {}

      try {
        final atom = AtomFeed.parse(xml);
        if (atom.items != null) {
          for (final item in atom.items!) {
            if (item == null) continue;
            final parsed = _fromAtomItem(item, source, now);
            if (parsed != null) items.add(parsed);
          }
        }
        return items;
      } catch (_) {}

      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<ContentItem>> _fetchJsonFeed(FeedSource source) async {
    try {
      final res = await _dio.get<String>(
        source.url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final raw = res.data;
      if (raw == null || raw.isEmpty) return [];

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final itemsJson = json['items'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      final items = <ContentItem>[];

      for (final itemJson in itemsJson) {
        final item = itemJson as Map<String, dynamic>;
        final title = (item['title'] as String?)?.trim();
        if (title == null || title.isEmpty) continue;

        final contentText = item['content_text'] as String?;
        final contentHtml = item['content_html'] as String?;
        final summary = item['summary'] as String?;
        final url = item['url'] as String? ?? '';
        final publishedStr = item['date_published'] as String?;
        final published = publishedStr != null
            ? DateTime.tryParse(publishedStr) ?? now
            : now;
        final tags = (item['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        final fullText = contentText ?? summary;
        final displaySummary = _truncateSummary(summary ?? contentHtml);
        final id = '${source.id}-${_hashCode(title)}';
        final wordCount = fullText?.length ?? title.length;
        final readTime = (wordCount / 300).ceil().clamp(1, 30);

        items.add(ContentItem(
          id: id,
          title: title,
          summary: displaySummary ?? title,
          fullText: fullText,
          sourceName: source.name,
          sourceUrl: url,
          topics: [...source.topics, ...tags],
          publishedAt: published,
          fetchedAt: now,
          estimatedReadTimeMinutes: readTime,
        ));
      }

      return items;
    } catch (_) {
      return [];
    }
  }

  ContentItem? _fromRssItem(RssItem item, FeedSource source, DateTime now) {
    final title = item.title?.trim();
    if (title == null || title.isEmpty) return null;

    final description = item.description?.trim();
    final link = item.link?.trim() ?? '';
    final rawPubDate = item.pubDate;
    final pubDate = rawPubDate != null
        ? DateTime.tryParse(rawPubDate.toString()) ?? now
        : now;

    final categories = item.categories
            ?.map((c) => c.value?.trim())
            .where((c) => c != null && c.isNotEmpty)
            .cast<String>()
            .toList() ??
        [];

    final topics = [...source.topics, ...categories];
    final fullText = description;
    final summary = _truncateSummary(description);
    final id = '${source.id}-${_hashCode(title)}';
    final wordCount = fullText?.length ?? title.length;
    final readTime = (wordCount / 300).ceil().clamp(1, 30);

    return ContentItem(
      id: id,
      title: title,
      summary: summary ?? title,
      fullText: fullText,
      sourceName: source.name,
      sourceUrl: link,
      topics: topics,
      publishedAt: pubDate,
      fetchedAt: now,
      estimatedReadTimeMinutes: readTime,
    );
  }

  ContentItem? _fromAtomItem(AtomItem item, FeedSource source, DateTime now) {
    final title = item.title?.trim();
    if (title == null || title.isEmpty) return null;

    final summary = item.summary?.trim();
    final content = item.content?.trim();
    final link = item.links?.isNotEmpty == true ? item.links!.first.href?.trim() ?? '' : '';
    final rawPublished = item.published;
    final published = rawPublished != null
        ? DateTime.tryParse(rawPublished.toString()) ?? now
        : now;
    final topics = [...source.topics];
    final fullText = content ?? summary;
    final displaySummary = _truncateSummary(summary ?? content);
    final id = '${source.id}-${_hashCode(title)}';
    final wordCount = fullText?.length ?? title.length;
    final readTime = (wordCount / 300).ceil().clamp(1, 30);

    return ContentItem(
      id: id,
      title: title,
      summary: displaySummary ?? title,
      fullText: fullText,
      sourceName: source.name,
      sourceUrl: link,
      topics: topics,
      publishedAt: published,
      fetchedAt: now,
      estimatedReadTimeMinutes: readTime,
    );
  }

  String? _truncateSummary(String? text) {
    if (text == null) return null;
    final cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (cleaned.length <= 200) return cleaned;
    return '${cleaned.substring(0, 200)}…';
  }

  int _hashCode(String s) {
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = 31 * hash + s.codeUnitAt(i);
    }
    return hash.abs();
  }
}

final feedFetcherProvider = Provider<FeedFetcher>((ref) {
  return FeedFetcher();
});
