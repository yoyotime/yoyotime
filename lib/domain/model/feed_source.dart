import 'value_object.dart';

class FeedSource extends ValueObject<FeedSource> {
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

  @override
  FeedSource get props => this;

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
