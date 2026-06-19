import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_bus.dart';

final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(() => bus.clear());
  return bus;
});
