import '../model/content_item.dart';
import '../model/feed_source.dart';

abstract class FeedSourceRepository {
  Future<List<FeedSource>> getAll();
  Future<FeedSource?> getById(String id);
  Future<void> save(FeedSource source);
  Future<void> delete(String id);
  Future<List<FeedSource>> getEnabled();
  Future<List<ContentItem>> fetchAll();
  List<String> get lastErrors;
}
