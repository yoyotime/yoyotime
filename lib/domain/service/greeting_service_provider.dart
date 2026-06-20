import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'greeting_service.dart';

final greetingServiceProvider = Provider<GreetingService>((ref) {
  return GreetingService();
});

// Alias for backward compatibility
final greetingServiceProviderLegacy = Provider<GreetingService>((ref) {
  return ref.watch(greetingServiceProvider);
});
