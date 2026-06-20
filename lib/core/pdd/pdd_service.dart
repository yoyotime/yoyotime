import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pdd_api.dart';
import 'pdd_config.dart';

class PddService {
  final PddConfig _config;
  PddApi? _api;

  PddService(this._config);

  bool get isConfigured => _api?.isConfigured ?? false;

  Future<void> refreshApi() async {
    final id = await _config.getClientId();
    final secret = await _config.getClientSecret();
    if (id != null && secret != null) {
      _api = PddApi(clientId: id, clientSecret: secret);
    } else {
      _api = null;
    }
  }

  Future<List<PddApiResult>> search(String keyword, {int page = 1, int pageSize = 20}) async {
    await refreshApi();
    if (_api == null) return [];
    return _api!.searchGoods(keyword: keyword, page: page, pageSize: pageSize);
  }
}

final pddServiceProvider = Provider<PddService>((ref) {
  final config = ref.read(pddConfigProvider);
  return PddService(config);
});

final pddSearchResultsProvider = FutureProvider.family<List<PddApiResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final service = ref.read(pddServiceProvider);
  return service.search(query.trim());
});

final pddConfiguredProvider = FutureProvider<bool>((ref) async {
  final config = ref.read(pddConfigProvider);
  final id = await config.getClientId();
  final secret = await config.getClientSecret();
  return id != null && secret != null;
});
