import 'content_media.dart';
import 'feedback_action.dart';

class ContentItem {
  final String id;
  final String title;
  final String summary;
  final String? fullText;
  final String sourceName;
  final String sourceUrl;
  final List<ContentMedia> media;
  final List<String> topics;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final int estimatedReadTimeMinutes;

  const ContentItem({
    required this.id,
    required this.title,
    required this.summary,
    this.fullText,
    required this.sourceName,
    required this.sourceUrl,
    this.media = const [],
    this.topics = const [],
    required this.publishedAt,
    required this.fetchedAt,
    this.estimatedReadTimeMinutes = 3,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
        id: json['content_id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        fullText: json['full_text'] as String?,
        sourceName: json['source']['name'] as String,
        sourceUrl: json['source']['url'] as String,
        media: (json['media'] as List<dynamic>?)
                ?.map((e) => ContentMedia.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        topics: List<String>.from(json['topics'] ?? []),
        publishedAt: DateTime.parse(json['published_at'] as String),
        fetchedAt: DateTime.parse(json['fetched_at'] as String),
        estimatedReadTimeMinutes: json['estimated_read_time_minutes'] as int? ?? 3,
      );

  ContentItem copyWith({
    String? fullText,
    List<ContentMedia>? media,
  }) =>
      ContentItem(
        id: id,
        title: title,
        summary: summary,
        fullText: fullText ?? this.fullText,
        sourceName: sourceName,
        sourceUrl: sourceUrl,
        media: media ?? this.media,
        topics: topics,
        publishedAt: publishedAt,
        fetchedAt: fetchedAt,
        estimatedReadTimeMinutes: estimatedReadTimeMinutes,
      );

  bool matchesBlocklist(List<String> blocklist) {
    return blocklist.any((word) =>
        title.contains(word) ||
        summary.contains(word) ||
        topics.any((t) => t.contains(word)));
  }

  bool matchesFeedback(Map<String, FeedbackAction> feedback) {
    final fb = feedback[id];
    return fb == null || fb == FeedbackAction.like || fb == FeedbackAction.bookmark;
  }

  List<String> extractBlocklistKeywords() {
    final words = [...topics, ...title.split(RegExp(r'[\s,，。、]+'))];
    return words.where((w) => w.length >= 2).toList();
  }

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
