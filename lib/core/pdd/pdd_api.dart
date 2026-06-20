import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PddApiResult {
  final String goodsId;
  final String title;
  final String? imageUrl;
  final int groupPrice;
  final int normalPrice;
  final int promotionRate;
  final int couponDiscount;
  final bool hasCoupon;
  final String? salesTip;

  PddApiResult({
    required this.goodsId,
    required this.title,
    this.imageUrl,
    required this.groupPrice,
    required this.normalPrice,
    this.promotionRate = 0,
    this.couponDiscount = 0,
    this.hasCoupon = false,
    this.salesTip,
  });

  double get priceYuan => normalPrice / 100;
  double get groupPriceYuan => groupPrice / 100;
  double get commissionRatePercent => promotionRate / 100;
  int get volume => int.tryParse(salesTip?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

  factory PddApiResult.fromJson(Map<String, dynamic> json) => PddApiResult(
        goodsId: json['goods_id']?.toString() ?? '',
        title: json['goods_name'] as String? ?? '',
        imageUrl: json['goods_image_url'] as String?,
        groupPrice: int.tryParse(json['min_group_price']?.toString() ?? '0') ?? 0,
        normalPrice: int.tryParse(json['min_normal_price']?.toString() ?? '0') ?? 0,
        promotionRate: int.tryParse(json['promotion_rate']?.toString() ?? '0') ?? 0,
        couponDiscount: int.tryParse(json['coupon_discount']?.toString() ?? '0') ?? 0,
        hasCoupon: json['has_coupon'] as bool? ?? false,
        salesTip: json['sales_tip'] as String?,
      );
}

class PddApi {
  static const _gateway = 'https://gw-api.pinduoduo.com/api/router';

  final Dio _dio;
  final String? clientId;
  final String? clientSecret;

  PddApi({required this.clientId, required this.clientSecret})
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  bool get isConfigured => clientId != null && clientSecret != null;

  String _sign(Map<String, String> params, String secret) {
    final keys = params.keys.toList()..sort();
    final sortedStr = keys.map((k) => '$k${params[k]}').join();
    final digest = md5.convert(utf8.encode(sortedStr + secret));
    return digest.toString().toUpperCase();
  }

  Map<String, String> _buildParams({
    required String type,
    Map<String, String>? extra,
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    final params = <String, String>{
      'client_id': clientId!,
      'timestamp': timestamp,
      'type': type,
    };

    if (extra != null) {
      params.addAll(extra);
    }

    params['sign'] = _sign(params, clientSecret!);
    return params;
  }

  Future<List<PddApiResult>> searchGoods({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!isConfigured) return [];

    final extra = <String, String>{
      'keyword': keyword,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    final params = _buildParams(
      type: 'pdd.ddk.goods.search',
      extra: extra,
    );

    try {
      final response = await _dio.post(
        _gateway,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final body = response.data as Map<String, dynamic>;
      final resp = body['pdd_ddk_goods_search_response'] as Map<String, dynamic>?;
      if (resp == null) return [];

      final goodsList = resp['goods_list'] as List<dynamic>?;
      if (goodsList == null) return [];

      return goodsList
          .map((e) => PddApiResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

final pddApiProvider = Provider<PddApi>((ref) {
  return PddApi(clientId: null, clientSecret: null);
});
