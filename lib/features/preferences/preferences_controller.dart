import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/repository_providers.dart';
import '../../domain/event/event_bus_provider.dart';
import '../../domain/event/events.dart';
import '../../domain/model/models.dart';

class PreferencesController extends Notifier<UserPreferences> {
  late final PreferencesRepository _repo;

  @override
  UserPreferences build() {
    _repo = ref.watch(preferencesRepositoryProvider);
    Future.microtask(_load);
    return UserPreferences(description: '');
  }

  Future<void> _load() async {
    final prefs = await _repo.getPreferences();
    state = prefs;
  }

  Future<void> update(UserPreferences prefs) async {
    final oldMode = state.themeMode;
    state = prefs;
    await _repo.savePreferences(prefs);
    if (oldMode != prefs.themeMode) {
      ref.read(eventBusProvider).publish(ThemeChangedEvent(
        oldMode: oldMode,
        newMode: prefs.themeMode,
      ));
    }
  }

  Future<void> setDescription(String description) async {
    final updated = state.copyWith(description: description);
    await update(updated);
  }

  Future<void> addInterest(String topic) async {
    final updated = state.addInterest(topic);
    await update(updated);
  }

  Future<void> removeInterest(String topic) async {
    final updated = state.removeInterest(topic);
    await update(updated);
  }

  Future<void> addBlocklist(String word) async {
    try {
      final updated = state.addBlocklist(word);
      await update(updated);
    } catch (_) {}
  }

  Future<void> removeBlocklist(String word) async {
    final updated = state.removeBlocklist(word);
    await update(updated);
  }
}

final preferencesControllerProvider =
    NotifierProvider<PreferencesController, UserPreferences>(
        PreferencesController.new);
