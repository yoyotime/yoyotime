class PointRecord {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final String action;
  final int points;
  final DateTime createdAt;

  PointRecord({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.action,
    required this.points,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PointRecord.fromJson(Map<String, dynamic> json) => PointRecord(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        productId: json['product_id'] as String,
        productTitle: json['product_title'] as String? ?? '',
        action: json['action'] as String,
        points: json['points'] as int,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': productId,
        'product_title': productTitle,
        'action': action,
        'points': points,
        'created_at': createdAt.toIso8601String(),
      };
}
