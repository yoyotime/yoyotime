class Product {
  final String id;
  final String title;
  final String? imageUrl;
  final String description;
  final String affiliateUrl;
  final double price;
  final double? commission;
  final String? publisherId;
  final String? publisherName;
  final DateTime postedAt;
  final int pointsOnClick;
  final String source;

  Product({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.description,
    required this.affiliateUrl,
    required this.price,
    this.commission,
    this.publisherId,
    this.publisherName,
    DateTime? postedAt,
    this.pointsOnClick = 10,
    this.source = 'user',
  }) : postedAt = postedAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        description: json['description'] as String? ?? '',
        affiliateUrl: json['affiliate_url'] as String,
        price: (json['price'] as num).toDouble(),
        commission: (json['commission'] as num?)?.toDouble(),
        publisherId: json['publisher_id'] as String?,
        publisherName: json['publisher_name'] as String?,
        postedAt: DateTime.tryParse(json['posted_at'] as String? ?? '') ?? DateTime.now(),
        pointsOnClick: json['points_on_click'] as int? ?? 10,
        source: json['source'] as String? ?? 'user',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'description': description,
        'affiliate_url': affiliateUrl,
        'price': price,
        'commission': commission,
        'publisher_id': publisherId,
        'publisher_name': publisherName,
        'posted_at': postedAt.toIso8601String(),
        'points_on_click': pointsOnClick,
        'source': source,
      };
}
