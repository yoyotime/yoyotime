import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tbk_api.dart';
import 'tbk_config.dart';

class TbkService {
  final TbkConfig _config;
  TbkApi? _api;

  TbkService(this._config);

  bool get isConfigured => _api?.isConfigured ?? false;

  Future<void> refreshApi() async {
    final key = await _config.getAppKey();
    final secret = await _config.getAppSecret();
    if (key != null && secret != null) {
      _api = TbkApi(appKey: key, appSecret: secret);
    } else {
      _api = null;
    }
  }

  Future<List<TbkApiResult>> search(String keyword, {int page = 1, int pageSize = 20}) async {
    await refreshApi();
    if (_api == null) return [];
    final adzoneId = await _config.getAdzoneId();
    return _api!.searchMaterials(
      keyword: keyword,
      pageNo: page,
      pageSize: pageSize,
      adzoneId: adzoneId ?? '0',
    );
  }
}

final tbkServiceProvider = Provider<TbkService>((ref) {
  final config = ref.read(tbkConfigProvider);
  return TbkService(config);
});

final tbkSearchResultsProvider = FutureProvider.family<List<TbkApiResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final service = ref.read(tbkServiceProvider);
  return service.search(query.trim());
});

final tbkConfiguredProvider = FutureProvider<bool>((ref) async {
  final config = ref.read(tbkConfigProvider);
  final key = await config.getAppKey();
  final secret = await config.getAppSecret();
  return key != null && secret != null;
});
