import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyotime/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyotime/core/storage/storage_service.dart';
import 'package:yoyotime/core/storage/affiliate_storage.dart';
import 'package:yoyotime/core/tbk/tbk_config.dart';
import 'package:yoyotime/features/affiliate/services/popup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots and renders main shell', (WidgetTester tester) async {
    final container = ProviderContainer();
    await container.read(storageServiceProvider).init();
    await container.read(affiliateStorageProvider).init();
    await container.read(tbkConfigProvider).init();

    addTearDown(() {
      container.read(popupServiceProvider).stop();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const YoyotimeApp(),
      ),
    );
    await tester.pump();
    container.read(popupServiceProvider).stop();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
