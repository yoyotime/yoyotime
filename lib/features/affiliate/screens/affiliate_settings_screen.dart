import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/pdd/pdd_config.dart';
import '../../../core/pdd/pdd_service.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../core/tbk/tbk_config.dart';
import '../../../core/tbk/tbk_service.dart';
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
          _sectionHeader(context, '淘宝客 API'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('App Key'),
                  subtitle: Text(
                    ref.watch(tbkConfiguredProvider).whenOrNull(data: (c) => c ? '已配置' : '未配置') ?? '未配置',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editTbkConfig(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          _sectionHeader(context, '拼多多 API'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('Client ID'),
                  subtitle: Text(
                    ref.watch(pddConfiguredProvider).whenOrNull(data: (c) => c ? '已配置' : '未配置') ?? '未配置',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editPddConfig(context, ref),
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

  Future<void> _editTbkConfig(BuildContext context, WidgetRef ref) async {
    final config = ref.read(tbkConfigProvider);
    final appKeyCtrl = TextEditingController(text: await config.getAppKey() ?? '');
    final appSecretCtrl = TextEditingController(text: await config.getAppSecret() ?? '');
    final adzoneIdCtrl = TextEditingController(text: await config.getAdzoneId() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('淘宝客 API 配置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: appKeyCtrl,
                decoration: const InputDecoration(
                  labelText: 'App Key',
                  hintText: '从淘宝开放平台获取',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: appSecretCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'App Secret',
                  hintText: '从淘宝开放平台获取',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adzoneIdCtrl,
                decoration: const InputDecoration(
                  labelText: '推广位 ID (adzone_id)',
                  hintText: '在淘宝客后台创建',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '需要先在 open.taobao.com 注册开发者、创建应用、申请 tbk 权限',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      await config.setAppKey(appKeyCtrl.text.trim());
      await config.setAppSecret(appSecretCtrl.text.trim());
      await config.setAdzoneId(adzoneIdCtrl.text.trim());
      ref.invalidate(tbkConfiguredProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('淘宝客 API 配置已保存')),
        );
      }
    }
  }

  Future<void> _editPddConfig(BuildContext context, WidgetRef ref) async {
    final config = ref.read(pddConfigProvider);
    final clientIdCtrl = TextEditingController(text: await config.getClientId() ?? '');
    final clientSecretCtrl = TextEditingController(text: await config.getClientSecret() ?? '');
    final pidCtrl = TextEditingController(text: await config.getPid() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('拼多多 API 配置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: clientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  hintText: '从拼多多开放平台获取',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientSecretCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  hintText: '从拼多多开放平台获取',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pidCtrl,
                decoration: const InputDecoration(
                  labelText: '推广位 PID',
                  hintText: '多多进宝后台创建，格式: 12345_67890',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '需要先在 open.pinduoduo.com 注册开发者、创建应用、申请多多进宝权限',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      await config.setClientId(clientIdCtrl.text.trim());
      await config.setClientSecret(clientSecretCtrl.text.trim());
      await config.setPid(pidCtrl.text.trim());
      ref.invalidate(pddConfiguredProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('拼多多 API 配置已保存')),
        );
      }
    }
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
