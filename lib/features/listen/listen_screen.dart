import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tts/tts_service.dart';

class ListenScreen extends ConsumerStatefulWidget {
  const ListenScreen({super.key});

  @override
  ConsumerState<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends ConsumerState<ListenScreen> {
  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  List<Map<String, String>> _voices = [];
  String? _selectedVoice;

  Future<void> _loadVoices() async {
    final tts = ref.read(ttsServiceProvider);
    final voices = await tts.getVoices();
    final zhVoices = voices.where((v) => v['locale']?.startsWith('zh') == true).toList();
    setState(() {
      _voices = zhVoices;
      _selectedVoice = tts.voice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('听')),
      body: ListView(
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
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('使用说明', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    '在「今日」页面点击文章进入阅读界面，点击右下角「朗读」按钮即可收听文章内容。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
