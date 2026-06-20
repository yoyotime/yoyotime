class AffiliateUser {
  final String id;
  final String? nickname;
  final bool isRegistered;
  final int totalPoints;
  final double totalEarnings;
  final DateTime createdAt;

  AffiliateUser({
    required this.id,
    this.nickname,
    this.isRegistered = false,
    this.totalPoints = 0,
    this.totalEarnings = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AffiliateUser.fromJson(Map<String, dynamic> json) => AffiliateUser(
        id: json['id'] as String,
        nickname: json['nickname'] as String?,
        isRegistered: json['is_registered'] as bool? ?? false,
        totalPoints: json['total_points'] as int? ?? 0,
        totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'is_registered': isRegistered,
        'total_points': totalPoints,
        'total_earnings': totalEarnings,
        'created_at': createdAt.toIso8601String(),
      };

  AffiliateUser copyWith({
    String? nickname,
    bool? isRegistered,
    int? totalPoints,
    double? totalEarnings,
  }) =>
      AffiliateUser(
        id: id,
        nickname: nickname ?? this.nickname,
        isRegistered: isRegistered ?? this.isRegistered,
        totalPoints: totalPoints ?? this.totalPoints,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        createdAt: createdAt,
      );
}
