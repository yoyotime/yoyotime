import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/storage_service.dart';
import 'domain/event/event_handler_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(storageServiceProvider).init();
  container.read(eventHandlerProvider);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const YoyotimeApp(),
  ));
}
