import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TbkConfig {
  static const _appKeyKey = 'tbk_app_key_v1';
  static const _appSecretKey = 'tbk_app_secret_v1';
  static const _adzoneIdKey = 'tbk_adzone_id_v1';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<String?> getAppKey() async {
    await init();
    return _prefs.getString(_appKeyKey);
  }

  Future<void> setAppKey(String key) async {
    await init();
    await _prefs.setString(_appKeyKey, key);
  }

  Future<String?> getAppSecret() async {
    await init();
    return _prefs.getString(_appSecretKey);
  }

  Future<void> setAppSecret(String secret) async {
    await init();
    await _prefs.setString(_appSecretKey, secret);
  }

  Future<String?> getAdzoneId() async {
    await init();
    return _prefs.getString(_adzoneIdKey);
  }

  Future<void> setAdzoneId(String id) async {
    await init();
    await _prefs.setString(_adzoneIdKey, id);
  }
}

final tbkConfigProvider = Provider<TbkConfig>((ref) {
  return TbkConfig();
});
