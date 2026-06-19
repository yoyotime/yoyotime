import 'domain_event.dart';
import '../../shared/models/content.dart';

class ContentFetchedEvent extends DomainEvent {
  final int totalCount;
  final int filteredCount;
  final List<String> failedSources;
  ContentFetchedEvent({
    required this.totalCount,
    required this.filteredCount,
    this.failedSources = const [],
  });
}

class ContentDisplayedEvent extends DomainEvent {
  final String contentId;
  final String sourceName;
  ContentDisplayedEvent({required this.contentId, required this.sourceName});
}

class FeedbackGivenEvent extends DomainEvent {
  final String contentId;
  final FeedbackAction action;
  final String? reason;
  FeedbackGivenEvent({
    required this.contentId,
    required this.action,
    this.reason,
  });
}

class BlocklistUpdatedEvent extends DomainEvent {
  final String word;
  final bool added;
  BlocklistUpdatedEvent({required this.word, required this.added});
}

class DailyLimitReachedEvent extends DomainEvent {
  final int count;
  DailyLimitReachedEvent({required this.count});
}

class DailyCountIncrementedEvent extends DomainEvent {
  final String contentId;
  final int newCount;
  DailyCountIncrementedEvent({required this.contentId, required this.newCount});
}

class TtsPlaybackStartedEvent extends DomainEvent {
  final String contentId;
  TtsPlaybackStartedEvent({required this.contentId});
}

class TtsPlaybackStoppedEvent extends DomainEvent {
  TtsPlaybackStoppedEvent();
}

class ThemeChangedEvent extends DomainEvent {
  final AppThemeMode oldMode;
  final AppThemeMode newMode;
  ThemeChangedEvent({required this.oldMode, required this.newMode});
}
