import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyotime/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyotime/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots and renders main shell', (WidgetTester tester) async {
    final container = ProviderContainer();
    await container.read(storageServiceProvider).init();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const YoyotimeApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
