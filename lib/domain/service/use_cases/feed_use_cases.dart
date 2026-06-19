import '../model/content_item.dart';
import '../repository/content_repository.dart';
import '../repository/preferences_repository.dart';
import '../event/event_bus.dart';
import '../event/events.dart';

class CacheFeedUseCase {
  final ContentRepository _contentRepo;

  CacheFeedUseCase(this._contentRepo);

  Future<void> execute(List<ContentItem> items) async {
    await _contentRepo.saveCachedContents(items);
  }
}

class LoadCachedFeedUseCase {
  final ContentRepository _contentRepo;

  LoadCachedFeedUseCase(this._contentRepo);

  Future<List<ContentItem>> execute() async {
    return await _contentRepo.getCachedContents();
  }
}

class EnforceDailyLimitUseCase {
  final PreferencesRepository _prefsRepo;

  EnforceDailyLimitUseCase(this._prefsRepo);

  Future<bool> isLimitReached() async {
    final consumed = await _prefsRepo.getDailyConsumedCount();
    return consumed >= 10;
  }

  Future<int> getConsumedCount() async {
    return await _prefsRepo.getDailyConsumedCount();
  }
}

class ActOnContentUseCase {
  final ContentRepository _contentRepo;
  final PreferencesRepository _prefsRepo;
  final EventBus _eventBus;

  ActOnContentUseCase(this._contentRepo, this._prefsRepo, this._eventBus);

  Future<void> execute(ContentItem item, dynamic action) async {
    await _contentRepo.setFeedback(item.id, action);

    _eventBus.publish(FeedbackGivenEvent(
      contentId: item.id,
      action: action,
    ));

    if (action.toString().contains('dislike')) {
      final prefs = await _prefsRepo.getPreferences();
      final newWords = item.extractBlocklistKeywords()
          .where((w) => !prefs.blocklist.contains(w))
          .toList();

      for (final word in newWords) {
        _eventBus.publish(BlocklistUpdatedEvent(word: word, added: true));
      }

      var updatedPrefs = prefs;
      for (final word in newWords) {
        updatedPrefs = updatedPrefs.addBlocklist(word);
      }
      await _prefsRepo.savePreferences(updatedPrefs);
    }
  }
}
