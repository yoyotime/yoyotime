import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import '../../shared/models/content.dart';

class PreferencesController extends Notifier<UserPreferences> {
  late final StorageService _storage;

  @override
  UserPreferences build() {
    _storage = ref.watch(storageServiceProvider);
    Future.microtask(_load);
    return const UserPreferences(description: '');
  }

  Future<void> _load() async {
    final prefs = await _storage.getPreferences();
    state = prefs;
  }

  Future<void> update(UserPreferences prefs) async {
    state = prefs;
    await _storage.savePreferences(prefs);
  }

  Future<void> setDescription(String description) async {
    final updated = state.copyWith(description: description);
    await update(updated);
  }

  Future<void> addInterest(String topic) async {
    if (state.interests.contains(topic)) return;
    final updated = state.copyWith(interests: [...state.interests, topic]);
    await update(updated);
  }

  Future<void> removeInterest(String topic) async {
    final updated = state.copyWith(
      interests: state.interests.where((t) => t != topic).toList(),
    );
    await update(updated);
  }

  Future<void> addBlocklist(String topic) async {
    if (state.blocklist.contains(topic)) return;
    final updated = state.copyWith(blocklist: [...state.blocklist, topic]);
    await update(updated);
  }

  Future<void> removeBlocklist(String topic) async {
    final updated = state.copyWith(
      blocklist: state.blocklist.where((t) => t != topic).toList(),
    );
    await update(updated);
  }
}

final preferencesControllerProvider =
    NotifierProvider<PreferencesController, UserPreferences>(
        PreferencesController.new);

extension on UserPreferences {
  UserPreferences copyWith({
    String? description,
    List<String>? interests,
    List<String>? blocklist,
    bool? preferAudio,
    double? ttsSpeed,
  }) =>
      UserPreferences(
        description: description ?? this.description,
        interests: interests ?? this.interests,
        blocklist: blocklist ?? this.blocklist,
        preferAudio: preferAudio ?? this.preferAudio,
        ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      );
}
