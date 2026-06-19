import '../model/content_item.dart';
import '../model/feedback_action.dart';

abstract class ContentRepository {
  Future<List<ContentItem>> getCachedContents();
  Future<void> saveCachedContents(List<ContentItem> items);
  Future<Map<String, FeedbackAction>> getAllFeedback();
  Future<void> setFeedback(String contentId, FeedbackAction action);
}
