import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import '../../core/tts/tts_service.dart';
import '../../shared/models/content.dart';
import '../../shared/utils/html_utils.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String contentId;
  const ReaderScreen({super.key, required this.contentId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  ContentItem? _content;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = ref.read(storageServiceProvider);
    final contents = await storage.getCachedContents();
    ContentItem? found;
    for (final c in contents) {
      if (c.id == widget.contentId) {
        found = c;
        break;
      }
    }
    if (found != null) {
      setState(() {
        _content = found;
        _isLoading = false;
      });
      await storage.incrementDailyConsumedCount();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    final content = _content;
    if (content == null) return;
    final tts = ref.read(ttsServiceProvider);
    final text = stripHtml('${content.title}。${content.fullText ?? content.summary}');
    await tts.speak(text);
  }

  Future<void> _stop() async {
    await ref.read(ttsServiceProvider).stop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final content = _content;
    if (content == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('内容不存在')),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(content.sourceName, style: theme.textTheme.titleSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  content.sourceName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '  ·  ${content.estimatedReadTimeMinutes} 分钟',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              stripHtml(content.fullText ?? content.summary),
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (ref.read(ttsServiceProvider).isPlaying) {
            await _stop();
          } else {
            await _speak();
          }
        },
        icon: Consumer(
          builder: (context, ref, _) {
            final isPlaying = ref.watch(ttsServiceProvider).isPlaying;
            return Icon(isPlaying ? Icons.stop : Icons.volume_up);
          },
        ),
        label: Consumer(
          builder: (context, ref, _) {
            final isPlaying = ref.watch(ttsServiceProvider).isPlaying;
            return Text(isPlaying ? '停止' : '朗读');
          },
        ),
      ),
    );
  }
}

