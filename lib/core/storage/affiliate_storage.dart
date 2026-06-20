import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/affiliate_models.dart';

class AffiliateStorage {
  static const _userKey = 'affiliate_user_v1';
  static const _pointsKey = 'affiliate_points_v1';
  static const _productsFile = 'affiliate_products.json';
  static const _recordsFile = 'affiliate_records.json';
  static const _sourcesKey = 'affiliate_sources_v1';
  static const _seedProductsKey = 'affiliate_seeded_v1';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _seedDefaultProducts();
    _initialized = true;
  }

  Future<void> _seedDefaultProducts() async {
    final seeded = _prefs.getBool(_seedProductsKey);
    if (seeded == true) return;

    final defaultProducts = [
      Product(
        id: 'seed-1',
        title: '静音蓝牙降噪耳机',
        imageUrl: 'https://picsum.photos/seed/prod1/400/400',
        description: '高性价比主动降噪耳机，沉浸阅读好伴侣',
        affiliateUrl: 'https://s.click.taobao.com/example1',
        price: 299.0,
        commission: 15.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
      Product(
        id: 'seed-2',
        title: '智能阅读灯',
        imageUrl: 'https://picsum.photos/seed/prod2/400/400',
        description: '无蓝光护眼台灯，三种色温可调',
        affiliateUrl: 'https://s.click.taobao.com/example2',
        price: 159.0,
        commission: 8.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
      Product(
        id: 'seed-3',
        title: '竹木桌面收纳架',
        imageUrl: 'https://picsum.photos/seed/prod3/400/400',
        description: '简约日式桌面收纳，让阅读空间更整洁',
        affiliateUrl: 'https://s.click.taobao.com/example3',
        price: 69.0,
        commission: 5.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
      Product(
        id: 'seed-4',
        title: '便携式墨水屏平板',
        imageUrl: 'https://picsum.photos/seed/prod4/400/400',
        description: '10寸墨水屏，阅读书写两不误',
        affiliateUrl: 'https://s.click.taobao.com/example4',
        price: 2499.0,
        commission: 50.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
      Product(
        id: 'seed-5',
        title: '手冲咖啡套装',
        imageUrl: 'https://picsum.photos/seed/prod5/400/400',
        description: '慢生活从一杯手冲咖啡开始',
        affiliateUrl: 'https://s.click.taobao.com/example5',
        price: 128.0,
        commission: 10.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
      Product(
        id: 'seed-6',
        title: '瑜伽垫加宽加厚',
        imageUrl: 'https://picsum.photos/seed/prod6/400/400',
        description: '适合冥想和拉伸的加厚瑜伽垫',
        affiliateUrl: 'https://s.click.taobao.com/example6',
        price: 89.0,
        commission: 6.0,
        pointsOnClick: 5,
        source: '精选推荐',
      ),
    ];

    await saveProducts(defaultProducts);
    await _prefs.setBool(_seedProductsKey, true);
  }

  Future<File> _getProductsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _productsFile));
  }

  Future<File> _getRecordsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _recordsFile));
  }

  Future<List<Product>> getProducts() async {
    try {
      final file = await _getProductsFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    try {
      final file = await _getProductsFile();
      final json = jsonEncode(products.map((e) => e.toJson()).toList());
      await file.writeAsString(json);
    } catch (_) {}
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.insert(0, product);
    await saveProducts(products);
  }

  Future<void> removeProduct(String productId) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == productId);
    await saveProducts(products);
  }

  Future<AffiliateUser> getUser() async {
    await init();
    final raw = _prefs.getString(_userKey);
    if (raw == null) {
      return AffiliateUser(id: 'guest');
    }
    try {
      return AffiliateUser.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return AffiliateUser(id: 'guest');
    }
  }

  Future<void> saveUser(AffiliateUser user) async {
    await init();
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<List<PointRecord>> getPointRecords() async {
    try {
      final file = await _getRecordsFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PointRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePointRecords(List<PointRecord> records) async {
    try {
      final file = await _getRecordsFile();
      final json = jsonEncode(records.map((e) => e.toJson()).toList());
      await file.writeAsString(json);
    } catch (_) {}
  }

  Future<void> addPointRecord(PointRecord record) async {
    final records = await getPointRecords();
    records.insert(0, record);
    await savePointRecords(records);

    final user = await getUser();
    final updated = user.copyWith(totalPoints: user.totalPoints + record.points);
    await saveUser(updated);
  }

  Future<int> getTotalPoints() async {
    final user = await getUser();
    return user.totalPoints;
  }

  Future<List<String>> getProductSources() async {
    await init();
    return _prefs.getStringList(_sourcesKey) ?? [];
  }

  Future<void> saveProductSources(List<String> sources) async {
    await init();
    await _prefs.setStringList(_sourcesKey, sources);
  }
}

final affiliateStorageProvider = Provider<AffiliateStorage>((ref) {
  return AffiliateStorage();
});
