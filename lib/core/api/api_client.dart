import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/content.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  static const _baseUrl = 'https://api.yoyotime.app';
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            ));

  Future<ContentFeed> fetchFeed({
    required String userId,
    int page = 1,
    int size = 20,
    List<String> topics = const [],
  }) async {
    try {
      final res = await _dio.post('/v1/feed', data: {
        'user_id': userId,
        'page': page,
        'size': size,
        'filter': {'topics': topics},
      });
      return ContentFeed.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_describe(e));
    }
  }

  Future<void> sendFeedback({
    required String userId,
    required String contentId,
    required FeedbackAction action,
  }) async {
    try {
      await _dio.post('/v1/feedback', data: {
        'user_id': userId,
        'content_id': contentId,
        'action': action.name,
      });
    } on DioException catch (e) {
      throw ApiException(_describe(e));
    }
  }

  Future<UserPreferences> updatePreferences({
    required String userId,
    required UserPreferences preferences,
  }) async {
    try {
      final res = await _dio.post(
        '/v1/preferences',
        data: {'user_id': userId, ...preferences.toJson()},
      );
      return UserPreferences.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_describe(e));
    }
  }

  String _describe(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return '网络似乎睡着了，请稍后再试';
    }
    if (e.type == DioExceptionType.connectionError) {
      return '连接不上服务，请检查网络';
    }
    return '出了点小问题：${e.message ?? e.type.name}';
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
