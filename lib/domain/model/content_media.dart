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
