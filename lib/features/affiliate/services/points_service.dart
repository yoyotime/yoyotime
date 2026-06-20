import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';

class PointsService {
  final AffiliateStorage _storage;

  PointsService(this._storage);

  static const _pointsPerYuan = 100;

  Future<int> earnClickPoints(Product product) async {
    final user = await _storage.getUser();
    if (!user.isRegistered) return 0;

    final record = PointRecord(
      id: 'click-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      productId: product.id,
      productTitle: product.title,
      action: 'click',
      points: product.pointsOnClick,
    );
    await _storage.addPointRecord(record);
    return product.pointsOnClick;
  }

  Future<double> convertPointsToMoney(int points) async {
    final user = await _storage.getUser();
    if (!user.isRegistered) return 0.0;

    final earnings = points / _pointsPerYuan;
    final record = PointRecord(
      id: 'convert-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      productId: 'convert',
      productTitle: '积分兑换',
      action: 'convert',
      points: -points,
    );
    await _storage.addPointRecord(record);
    await _storage.saveUser(user.copyWith(
      totalPoints: user.totalPoints - points,
      totalEarnings: user.totalEarnings + earnings,
    ));
    return earnings;
  }

  Future<void> recordCommission(double amount) async {
    final user = await _storage.getUser();
    if (!user.isRegistered) return;

    final record = PointRecord(
      id: 'commission-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      productId: 'commission',
      productTitle: '推广佣金',
      action: 'commission',
      points: 0,
    );
    await _storage.addPointRecord(record);
    await _storage.saveUser(user.copyWith(
      totalEarnings: user.totalEarnings + amount,
    ));
  }

  Future<int> getTotalPoints() => _storage.getTotalPoints();

  Future<AffiliateUser> getUser() => _storage.getUser();

  Future<List<PointRecord>> getRecords() => _storage.getPointRecords();
}

final pointsServiceProvider = Provider<PointsService>((ref) {
  final storage = ref.read(affiliateStorageProvider);
  return PointsService(storage);
});
