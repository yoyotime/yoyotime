import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tts/tts_service.dart';
import '../feed/audio_player_controller.dart';

class ListenScreen extends ConsumerStatefulWidget {
  const ListenScreen({super.key});

  @override
  ConsumerState<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends ConsumerState<ListenScreen> {
  List<Map<String, String>> _voices = [];
  String? _selectedVoice;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = ref.read(ttsServiceProvider);
    final voices = await tts.getVoices();
    final zhVoices =
        voices.where((v) => v['locale']?.startsWith('zh') == true).toList();
    setState(() {
      _voices = zhVoices;
      _selectedVoice = tts.voice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tts = ref.watch(ttsServiceProvider);
    final playerState = ref.watch(audioPlayerProvider);
    final controller = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_showSettings ? '语音设置' : '听'),
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.headphones : Icons.settings),
            onPressed: () => setState(() => _showSettings = !_showSettings),
            tooltip: _showSettings ? '播放列表' : '语音设置',
          ),
        ],
      ),
      body: _showSettings
          ? _buildSettings(theme, tts)
          : _buildPlayer(theme, playerState, controller, tts),
    );
  }

  Widget _buildPlayer(ThemeData theme, AudioPlayerState playerState,
      AudioPlayerController controller, TtsService tts) {
    if (playerState.queue.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.headphones_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              '还没有播放内容',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              '在「今日」页面点击文章上的播放按钮\n或使用「全部播放」按钮添加内容',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    final current = playerState.current;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.play_circle_filled,
                    size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  '正在播放',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 8),
                Text(
                  current?.title ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${playerState.currentIndex + 1} / ${playerState.queue.length}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: controller.playPrevious,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          playerState.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          if (playerState.isPaused) {
                            controller.resume();
                          } else {
                            controller.pause();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: controller.playNext,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: controller.stop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '播放列表',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(playerState.queue.length, (i) {
          final item = playerState.queue[i];
          final isCurrent = i == playerState.currentIndex;
          return Card(
            color: isCurrent ? theme.colorScheme.primaryContainer : null,
            child: ListTile(
              leading: isCurrent
                  ? Icon(Icons.play_arrow, color: theme.colorScheme.primary)
                  : const Icon(Icons.article_outlined),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontWeight: isCurrent ? FontWeight.w600 : null),
              ),
              subtitle: Text(item.sourceName),
              trailing:
                  isCurrent ? null : const Icon(Icons.skip_next, size: 18),
              onTap: isCurrent
                  ? null
                  : () {
                      controller.playAll(playerState.queue, startIndex: i);
                    },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSettings(ThemeData theme, TtsService tts) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('语音设置', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                Text('语速', style: theme.textTheme.bodyMedium),
                Slider(
                  value: tts.speed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${tts.speed.toStringAsFixed(1)}x',
                  onChanged: (v) => tts.setSpeed(v),
                ),
                const SizedBox(height: 16),
                if (_voices.isNotEmpty) ...[
                  Text('音色', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final voice in _voices)
                        ChoiceChip(
                          label: Text(voice['name'] ?? '未知'),
                          selected: _selectedVoice == voice['name'],
                          onSelected: (_) {
                            tts.setVoice(voice['name']);
                            setState(() => _selectedVoice = voice['name']);
                          },
                        ),
                    ],
                  ),
                ] else
                  const Text('正在加载可用音色...'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
