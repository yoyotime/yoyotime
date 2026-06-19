import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../domain/repository/repository_providers.dart';
import '../../domain/event/event_bus_provider.dart';
import '../../domain/event/events.dart';
import '../../domain/model/models.dart';
import '../../shared/utils/html_utils.dart';
import '../../shared/widgets/breathing_animation.dart';
import '../../core/tts/tts_service.dart';
import '../../core/storage/storage_service.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String contentId;
  const ReaderScreen({super.key, required this.contentId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  ContentItem? _content;
  bool _isLoading = true;
  bool _showBreathing = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(contentRepositoryProvider);
    final contents = await repo.getCachedContents();
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
      await repo.incrementDailyConsumedCount();
      if (repo is StorageService) {
        await repo.trackRead(found.id);
      }
      ref.read(eventBusProvider).publish(ContentDisplayedEvent(
        contentId: found.id,
        sourceName: found.sourceName,
      ));
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    final content = _content;
    if (content == null) return;
    final tts = ref.read(ttsServiceProvider);
    final text = stripHtml('${content.title}。${content.fullText ?? content.summary}');
    ref.read(eventBusProvider).publish(TtsPlaybackStartedEvent(contentId: content.id));
    await tts.speak(text);

    if (tts.lastError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tts.lastError!),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stop() async {
    ref.read(eventBusProvider).publish(TtsPlaybackStoppedEvent());
    await ref.read(ttsServiceProvider).stop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showBreathing && _content != null) {
      return BreathingAnimation(
        onComplete: () => setState(() => _showBreathing = false),
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
            Html(
              data: content.fullText ?? content.summary,
              style: {
                'body': Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.8),
                ),
                'a': Style(
                  color: theme.colorScheme.primary,
                ),
                'img': Style(
                  width: Width(MediaQuery.of(context).size.width - 40),
                ),
              },
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

