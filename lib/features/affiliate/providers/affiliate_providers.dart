import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';
import '../services/popup_service.dart';
import '../services/points_service.dart';

final popupVisibleProvider = NotifierProvider<PopupVisibleNotifier, bool>(
  PopupVisibleNotifier.new,
);

class PopupVisibleNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.read(popupServiceProvider);
    service.onShowPopup = () => show();
    service.start();
    ref.onDispose(() => service.stop());
    return false;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final storage = ref.read(affiliateStorageProvider);
  return storage.getProducts();
});

final affiliateUserProvider = FutureProvider<AffiliateUser>((ref) async {
  final storage = ref.read(affiliateStorageProvider);
  return storage.getUser();
});

final pointRecordsProvider = FutureProvider<List<PointRecord>>((ref) async {
  final pointsService = ref.read(pointsServiceProvider);
  return pointsService.getRecords();
});

final productSourcesProvider = FutureProvider<List<String>>((ref) async {
  final storage = ref.read(affiliateStorageProvider);
  return storage.getProductSources();
});
