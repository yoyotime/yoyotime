import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tts/tts_service.dart';
import 'preferences_controller.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  late TextEditingController _descController;
  late TextEditingController _interestController;
  late TextEditingController _blockController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
    _interestController = TextEditingController();
    _blockController = TextEditingController();
  }

  @override
  void dispose() {
    _descController.dispose();
    _interestController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);
    final tts = ref.watch(ttsServiceProvider);

    if (!_initialized) {
      _descController.text = prefs.description;
      _initialized = true;
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('我')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _sectionTitle(theme, '你是什么样的人'),
          const SizedBox(height: 8),
          Text(
            '用一段话告诉悠悠时光你在意什么，避开什么。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '例如：我是一位妈妈，关心儿童安全和防拐卖信息，关注国家大事和和平消息……',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setDescription(v),
          ),
          const SizedBox(height: 32),
          _sectionTitle(theme, '我关心的'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in prefs.interests)
                InputChip(
                  label: Text(t),
                  onDeleted: () => controller.removeInterest(t),
                ),
              _addChip(
                controller: _interestController,
                hint: '+ 添加',
                onSubmit: () {
                  final v = _interestController.text.trim();
                  if (v.isNotEmpty) {
                    controller.addInterest(v);
                    _interestController.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sectionTitle(theme, '我不想看的'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in prefs.blocklist)
                InputChip(
                  label: Text(t),
                  backgroundColor: theme.colorScheme.errorContainer,
                  onDeleted: () => controller.removeBlocklist(t),
                ),
              _addChip(
                controller: _blockController,
                hint: '+ 添加',
                onSubmit: () {
                  final v = _blockController.text.trim();
                  if (v.isNotEmpty) {
                    controller.addBlocklist(v);
                    _blockController.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sectionTitle(theme, '声音'),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '朗读语速',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      const Text('0.8x'),
                      Expanded(
                        child: Slider(
                          value: tts.speed,
                          min: 0.8,
                          max: 2.0,
                          divisions: 12,
                          label: '${tts.speed.toStringAsFixed(1)}x',
                          onChanged: (v) => tts.setSpeed(v),
                        ),
                      ),
                      const Text('2.0x'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _addChip({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSubmit,
  }) {
    return SizedBox(
      width: 110,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => onSubmit(),
        onEditingComplete: onSubmit,
      ),
    );
  }
}
