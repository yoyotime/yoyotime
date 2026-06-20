import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareContent({
    required String title,
    required String summary,
    required String sourceName,
    required int readTime,
  }) async {
    final text = '''$title

${summary.length > 100 ? '${summary.substring(0, 100)}...' : summary}

来自「悠悠时光」|$sourceName · $readTime分钟''';

    await SharePlus.instance.share(ShareParams(text: text));
  }
}
