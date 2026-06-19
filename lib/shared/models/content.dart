class ContentMedia {
  final String type;
  final String url;
  final String? alt;
  final int? duration;

  const ContentMedia({
    required this.type,
    required this.url,
    this.alt,
    this.duration,
  });

  factory ContentMedia.fromJson(Map<String, dynamic> json) => ContentMedia(
        type: json['type'] as String,
        url: json['url'] as String,
        alt: json['alt'] as String?,
        duration: json['duration'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        if (alt != null) 'alt': alt,
        if (duration != null) 'duration': duration,
      };
}

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
}

class ContentFeed {
  final List<ContentItem> items;
  final int page;
  final bool hasMore;

  const ContentFeed({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory ContentFeed.fromJson(Map<String, dynamic> json) => ContentFeed(
        items: (json['items'] as List<dynamic>)
            .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: json['page'] as int,
        hasMore: json['has_more'] as bool,
      );
}

enum FeedbackAction { like, dislike, delete, bookmark }

enum AppThemeMode { light, dark, reading, system }

class UserPreferences {
  final String description;
  final List<String> interests;
  final List<String> blocklist;
  final bool preferAudio;
  final double ttsSpeed;
  final AppThemeMode themeMode;

  const UserPreferences({
    required this.description,
    this.interests = const [],
    this.blocklist = const [],
    this.preferAudio = false,
    this.ttsSpeed = 1.0,
    this.themeMode = AppThemeMode.system,
  });

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
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'interests': interests,
        'blocklist': blocklist,
        'prefer_audio': preferAudio,
        'tts_speed': ttsSpeed,
        'theme_mode': themeMode.name,
      };
}
