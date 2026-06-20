import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TbkApiResult {
  final String itemId;
  final String title;
  final String? imageUrl;
  final String price;
  final String? reservePrice;
  final String? commissionRate;
  final String? clickUrl;
  final String? couponUrl;
  final int volume;

  TbkApiResult({
    required this.itemId,
    required this.title,
    this.imageUrl,
    required this.price,
    this.reservePrice,
    this.commissionRate,
    this.clickUrl,
    this.couponUrl,
    this.volume = 0,
  });

  factory TbkApiResult.fromJson(Map<String, dynamic> json) => TbkApiResult(
        itemId: json['item_id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        imageUrl: json['pict_url'] as String?,
        price: json['zk_final_price']?.toString() ?? '0',
        reservePrice: json['reserve_price']?.toString(),
        commissionRate: json['commission_rate']?.toString(),
        clickUrl: json['click_url'] as String?,
        couponUrl: json['coupon_click_url'] as String?,
        volume: int.tryParse(json['volume']?.toString() ?? '0') ?? 0,
      );
}

class TbkApi {
  static const _gateway = 'https://eco.taobao.com/router/rest';

  final Dio _dio;
  final String? appKey;
  final String? appSecret;

  TbkApi({required this.appKey, required this.appSecret})
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  bool get isConfigured => appKey != null && appSecret != null;

  String _sign(Map<String, String> params, String secret) {
    final keys = params.keys.toList()..sort();
    final sortedStr = keys.map((k) => '$k${params[k]}').join();
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(sortedStr));
    return digest.toString().toUpperCase();
  }

  Map<String, String> _buildParams({
    required String method,
    Map<String, String>? extra,
  }) {
    final now = DateTime.now();
    final ts =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)} ${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';

    final params = <String, String>{
      'method': method,
      'app_key': appKey!,
      'timestamp': ts,
      'format': 'json',
      'v': '2.0',
      'sign_method': 'hmac-sha256',
    };

    if (extra != null) {
      params.addAll(extra);
    }

    params['sign'] = _sign(params, appSecret!);
    return params;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<List<TbkApiResult>> searchMaterials({
    required String keyword,
    int pageNo = 1,
    int pageSize = 20,
    String? adzoneId,
  }) async {
    if (!isConfigured) return [];

    final extra = <String, String>{
      'q': keyword,
      'page_no': pageNo.toString(),
      'page_size': pageSize.toString(),
      'adzone_id': adzoneId ?? '0',
      'site_id': appKey!,
    };

    final params = _buildParams(
      method: 'taobao.tbk.dg.material.optional',
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
      final resultKey = 'tbk_dg_material_optional_response';
      final result = body[resultKey] as Map<String, dynamic>?;
      if (result == null) return [];

      final resultList = result['result_list'] as Map<String, dynamic>?;
      if (resultList == null) return [];

      final mapData = resultList['map_data'] as List<dynamic>?;
      if (mapData == null) return [];

      return mapData
          .map((e) => TbkApiResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

final tbkApiProvider = Provider<TbkApi>((ref) {
  return TbkApi(appKey: null, appSecret: null);
});
