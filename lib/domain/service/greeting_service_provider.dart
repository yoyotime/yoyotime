import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'greeting_service.dart';

final greetingServiceProvider = Provider<GreetingService>((ref) {
  return GreetingService();
});
