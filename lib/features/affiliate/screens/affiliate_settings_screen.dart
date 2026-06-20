import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../providers/affiliate_providers.dart';

class AffiliateSettingsScreen extends ConsumerWidget {
  const AffiliateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(affiliateUserProvider);
    final sourcesAsync = ref.watch(productSourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('好物设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, '账号'),
          Card(
            child: userAsync.when(
              data: (user) => ListTile(
                leading: Icon(
                  user.isRegistered ? Icons.person : Icons.person_outline,
                  color: user.isRegistered ? Colors.amber[700] : null,
                ),
                title: Text(user.isRegistered ? (user.nickname ?? '已注册用户') : '未注册游客'),
                subtitle: Text(user.isRegistered ? '积分: ${user.totalPoints}' : '注册后可赚积分'),
                trailing: user.isRegistered
                    ? TextButton(
                        onPressed: () => context.push('/affiliate/points'),
                        child: const Text('查看积分'),
                      )
                    : FilledButton.tonalIcon(
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('注册'),
                        onPressed: () => context.push('/affiliate/register'),
                      ),
              ),
              loading: () => const ListTile(title: Text('加载中…')),
              error: (e, _) => ListTile(title: Text('加载失败: $e')),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '商品来源'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rss_feed),
                  title: const Text('精选推荐'),
                  subtitle: const Text('系统预设推荐商品'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('用户发布'),
                  subtitle: const Text('注册用户发布的商品'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('推广链接源'),
                  subtitle: const Text('添加淘宝客等推广渠道'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editSources(context, ref, sourcesAsync),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, '我的发布'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('我发布的商品'),
              subtitle: const Text('管理已发布的商品'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/affiliate/publish'),
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

  Future<void> _editSources(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<String>> sourcesAsync,
  ) async {
    final sources = sourcesAsync.whenOrNull(data: (s) => s) ?? [];
    final ctrl = TextEditingController();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('推广链接源'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                            hintText: '添加来源 (如: 淘宝客)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (ctrl.text.trim().isNotEmpty) {
                            setDialogState(() {
                              sources.add(ctrl.text.trim());
                            });
                            ctrl.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (sources.isEmpty)
                    Text('暂无自定义来源', style: TextStyle(color: Colors.grey[500]))
                  else
                    Expanded(
                      child: ListView(
                        children: sources
                            .map((s) => ListTile(
                                  dense: true,
                                  title: Text(s),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => setDialogState(() => sources.remove(s)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, sources),
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null) {
      final storage = ref.read(affiliateStorageProvider);
      await storage.saveProductSources(result);
      ref.invalidate(productSourcesProvider);
    }
  }
}
