import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PddConfig {
  static const _clientIdKey = 'pdd_client_id_v1';
  static const _clientSecretKey = 'pdd_client_secret_v1';
  static const _pidKey = 'pdd_pid_v1';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<String?> getClientId() async {
    await init();
    return _prefs.getString(_clientIdKey);
  }

  Future<void> setClientId(String id) async {
    await init();
    await _prefs.setString(_clientIdKey, id);
  }

  Future<String?> getClientSecret() async {
    await init();
    return _prefs.getString(_clientSecretKey);
  }

  Future<void> setClientSecret(String secret) async {
    await init();
    await _prefs.setString(_clientSecretKey, secret);
  }

  Future<String?> getPid() async {
    await init();
    return _prefs.getString(_pidKey);
  }

  Future<void> setPid(String pid) async {
    await init();
    await _prefs.setString(_pidKey, pid);
  }
}

final pddConfigProvider = Provider<PddConfig>((ref) {
  return PddConfig();
});
