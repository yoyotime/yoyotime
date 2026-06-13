import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReleaseInfo {
  final String tagName;
  final String htmlUrl;
  final String body;
  final List<AssetInfo> assets;

  const ReleaseInfo({
    required this.tagName,
    required this.htmlUrl,
    required this.body,
    this.assets = const [],
  });
}

class AssetInfo {
  final String name;
  final String downloadUrl;
  final int size;

  const AssetInfo({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });
}

class UpdateService {
  final Dio _dio;
  String? _currentVersion;

  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> getCurrentVersion() async {
    if (_currentVersion != null) return _currentVersion!;
    final info = await PackageInfo.fromPlatform();
    _currentVersion = 'v${info.version}';
    return _currentVersion!;
  }

  Future<ReleaseInfo?> checkForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configRaw = await rootBundle.loadString('assets/config/app_config.json');
      final config = jsonDecode(configRaw) as Map<String, dynamic>;
      final apiUrl = config['api_url'] as String;

      final res = await _dio.get<String>(
        apiUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      final data = jsonDecode(res.data!) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      if (tagName.isEmpty) return null;

      final skipKey = 'update_skip_$tagName';
      if (prefs.getBool(skipKey) == true) return null;

      final current = await getCurrentVersion();
      if (!_isNewer(tagName, current)) return null;

      final htmlUrl = data['html_url'] as String? ?? '';
      final body = data['body'] as String? ?? '';
      final assetsList = (data['assets'] as List<dynamic>?)
              ?.map((a) {
                final m = a as Map<String, dynamic>;
                return AssetInfo(
                  name: m['name'] as String? ?? '',
                  downloadUrl: m['browser_download_url'] as String? ?? '',
                  size: m['size'] as int? ?? 0,
                );
              })
              .where((a) => a.name.endsWith('.apk'))
              .toList() ??
          [];

      return ReleaseInfo(
        tagName: tagName,
        htmlUrl: htmlUrl,
        body: body,
        assets: assetsList,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isNewer(String remote, String current) {
    final clean = (String v) => v.replaceAll(RegExp(r'^v'), '');
    final rParts = clean(remote).split('.').map(int.tryParse).toList();
    final cParts = clean(current).split('.').map(int.tryParse).toList();
    for (int i = 0; i < 3; i++) {
      final r = (i < rParts.length ? rParts[i] : 0) ?? 0;
      final c = (i < cParts.length ? cParts[i] : 0) ?? 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  Future<String?> downloadApk(
    String url,
    String fileName,
    void Function(int received, int total) onProgress,
  ) async {
    try {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$fileName');
      await _dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          onProgress(received, total ?? -1);
        },
      );
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> installApk(String filePath) async {
    await OpenFilex.open(filePath);
  }

  Future<void> markSkipped(String tagName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('update_skip_$tagName', true);
  }
}

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});
