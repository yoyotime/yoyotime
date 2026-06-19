import '../model/content_item.dart';
import '../model/feed_source.dart';

abstract class FeedSourceRepository {
  Future<List<FeedSource>> loadSources();
  Future<List<ContentItem>> fetchAll();
  List<String> get lastErrors;
}
