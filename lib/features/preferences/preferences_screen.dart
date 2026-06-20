import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/tts/tts_service.dart';
import '../../core/update/update_service.dart';
import '../../shared/models/content.dart';
import '../../shared/widgets/voice_input_dialog.dart';
import 'preferences_controller.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, '兴趣描述'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prefs.description.isNotEmpty
                        ? prefs.description
                        : '还没有描述你的兴趣…',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('编辑'),
                        onPressed: () => _editDescription(context, controller, prefs.description),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.mic, size: 16),
                        label: const Text('语音'),
                        onPressed: () => _voiceInput(context, controller),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '我关心的'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...prefs.interests.map((t) => Chip(
                    label: Text(t),
                    onDeleted: () => controller.removeInterest(t),
                  )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('添加'),
                onPressed: () => _addTopic(context, controller, true),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '不想看的'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...prefs.blocklist.map((t) => Chip(
                    label: Text(t),
                    onDeleted: () => controller.removeBlocklist(t),
                  )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('添加'),
                onPressed: () => _addTopic(context, controller, false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '声音设置'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('语速'),
                      Expanded(
                        child: Slider(
                          value: prefs.ttsSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: '${prefs.ttsSpeed.toStringAsFixed(1)}x',
                          onChanged: (v) {
                            controller.update(UserPreferences(
                              description: prefs.description,
                              interests: prefs.interests,
                              blocklist: prefs.blocklist,
                              preferAudio: prefs.preferAudio,
                              ttsSpeed: v,
                            ));
                            ref.read(ttsServiceProvider).setSpeed(v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${prefs.ttsSpeed.toStringAsFixed(1)}x',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '外观'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('主题模式', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ThemeChip(
                        icon: Icons.brightness_auto,
                        label: '跟随系统',
                        selected: prefs.themeMode == AppThemeMode.system,
                        onTap: () => controller.update(UserPreferences(
                          description: prefs.description,
                          interests: prefs.interests,
                          blocklist: prefs.blocklist,
                          preferAudio: prefs.preferAudio,
                          ttsSpeed: prefs.ttsSpeed,
                          themeMode: AppThemeMode.system,
                        )),
                      ),
                      _ThemeChip(
                        icon: Icons.light_mode,
                        label: '浅色',
                        selected: prefs.themeMode == AppThemeMode.light,
                        onTap: () => controller.update(UserPreferences(
                          description: prefs.description,
                          interests: prefs.interests,
                          blocklist: prefs.blocklist,
                          preferAudio: prefs.preferAudio,
                          ttsSpeed: prefs.ttsSpeed,
                          themeMode: AppThemeMode.light,
                        )),
                      ),
                      _ThemeChip(
                        icon: Icons.dark_mode,
                        label: '深色',
                        selected: prefs.themeMode == AppThemeMode.dark,
                        onTap: () => controller.update(UserPreferences(
                          description: prefs.description,
                          interests: prefs.interests,
                          blocklist: prefs.blocklist,
                          preferAudio: prefs.preferAudio,
                          ttsSpeed: prefs.ttsSpeed,
                          themeMode: AppThemeMode.dark,
                        )),
                      ),
                      _ThemeChip(
                        icon: Icons.menu_book,
                        label: '阅读',
                        selected: prefs.themeMode == AppThemeMode.reading,
                        onTap: () => controller.update(UserPreferences(
                          description: prefs.description,
                          interests: prefs.interests,
                          blocklist: prefs.blocklist,
                          preferAudio: prefs.preferAudio,
                          ttsSpeed: prefs.ttsSpeed,
                          themeMode: AppThemeMode.reading,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '好物'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('好物推荐'),
              subtitle: const Text('看商品·赚积分·兑现金'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final router = GoRouter.of(context);
                router.push('/affiliate');
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('好物设置'),
              subtitle: const Text('商品来源、账号管理'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final router = GoRouter.of(context);
                router.push('/affiliate/settings');
              },
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '分享'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享给朋友'),
              subtitle: const Text('邀请好友一起安静地了解世界'),
              onTap: () => _shareApp(context),
            ),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, '关于'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: const Text('检查更新'),
                  subtitle: const Text('查看最新版本'),
                  onTap: () => _checkUpdate(context, ref),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('版本'),
                  subtitle: Text('v0.4.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Future<void> _editDescription(
    BuildContext context,
    PreferencesController controller,
    String current,
  ) async {
    final textCtrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('描述你的兴趣'),
        content: TextField(
          controller: textCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '例如：我关心国际局势和社会新闻，特别是儿童安全和和平相关的内容…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, textCtrl.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await controller.setDescription(result);
    }
  }

  Future<void> _voiceInput(BuildContext context, PreferencesController controller) async {
    final result = await showVoiceInputDialog(context, hint: '描述你的兴趣偏好');
    if (result != null && result.isNotEmpty) {
      await controller.setDescription(result);
    }
  }

  Future<void> _addTopic(
    BuildContext context,
    PreferencesController ctrl,
    bool isInterest,
  ) async {
    final textCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isInterest ? '添加感兴趣的话题' : '添加不想看的话题'),
        content: TextField(
          controller: textCtrl,
          decoration: InputDecoration(
            hintText: isInterest ? '如：儿童安全' : '如：娱乐八卦',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: () async {
                    final result = await showVoiceInputDialog(context, hint: isInterest ? '输入你感兴趣的话题' : '输入你不想看的话题');
                    if (result != null && result.isNotEmpty) {
                      textCtrl.text = result;
                    }
                  },
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, textCtrl.text),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (isInterest) {
        await ctrl.addInterest(result);
      } else {
        await ctrl.addBlocklist(result);
      }
    }
  }

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    final updateService = ref.read(updateServiceProvider);
    final release = await updateService.checkForUpdate();
    if (release == null || !context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }
    final install = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('发现新版本 ${release.tagName}'),
        content: SingleChildScrollView(
          child: Text(release.body.isNotEmpty ? release.body : '更新内容加载失败'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateService.markSkipped(release.tagName);
              Navigator.pop(ctx, false);
            },
            child: const Text('稍后提醒'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('下载更新'),
          ),
        ],
      ),
    );
    if (install == true && context.mounted) {
      _downloadAndInstall(context, updateService, release);
    }
  }

  Future<void> _downloadAndInstall(
    BuildContext context,
    UpdateService updateService,
    ReleaseInfo release,
  ) async {
    if (release.assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可下载的安装包')),
      );
      return;
    }
    final asset = release.assets.first;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('下载中…'),
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text('正在下载 ${asset.name}'),
          ],
        ),
      ),
    );
    final filePath = await updateService.downloadApk(
      asset.downloadUrl,
      asset.name,
      (received, total) {},
    );
    navigator.pop();
    if (filePath != null) {
      await updateService.installApk(filePath);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('下载失败，请稍后重试')),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final url = 'https://github.com/anomaloco/yoyotime/releases/latest';
    await SharePlus.instance.share(ShareParams(
      text: '推荐一个安静的好 App——悠悠时光，每天 10 条精选内容，反焦虑、反成瘾、反窥探。下载：$url',
    ));
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: selected ? theme.colorScheme.onPrimary : null),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.onPrimary : null,
      ),
    );
  }
}
