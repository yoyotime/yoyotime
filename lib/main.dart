import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(storageServiceProvider).init();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const YoyotimeApp(),
  ));
}
