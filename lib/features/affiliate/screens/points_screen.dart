import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';
import '../providers/affiliate_providers.dart';
import '../services/points_service.dart';

class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(affiliateUserProvider);
    final recordsAsync = ref.watch(pointRecordsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的积分')),
      body: userAsync.when(
        data: (user) {
          if (!user.isRegistered) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('注册后即可赚取积分'),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${user.totalPoints}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('当前积分', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      if (user.totalPoints >= 100)
                        FilledButton.icon(
                          icon: const Icon(Icons.monetization_on, size: 18),
                          label: Text(
                            '兑换 ¥${(user.totalPoints / 100).toStringAsFixed(1)}',
                          ),
                          onPressed: () => _convertPoints(context, ref, user.totalPoints),
                        )
                      else
                        Text(
                          '满 100 积分可兑换现金 (${100 - user.totalPoints} 积分差额)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      if (user.totalEarnings > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '累计收益: ¥${user.totalEarnings.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('积分记录', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('还没有积分记录', style: TextStyle(color: Colors.grey[500])),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: records.map((r) => _recordTile(r)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _recordTile(PointRecord record) {
    final isPositive = record.points > 0;
    return Card(
      child: ListTile(
        leading: Icon(
          isPositive ? Icons.add_circle : Icons.remove_circle,
          color: isPositive ? Colors.green : Colors.red,
          size: 20,
        ),
        title: Text(record.productTitle),
        subtitle: Text(_actionLabel(record.action)),
        trailing: Text(
          '${isPositive ? '+' : ''}${record.points}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'click':
        return '点击商品';
      case 'convert':
        return '积分兑换';
      case 'commission':
        return '推广佣金';
      default:
        return action;
    }
  }

  Future<void> _convertPoints(BuildContext context, WidgetRef ref, int totalPoints) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('兑换积分'),
        content: Text('确定将 ${totalPoints} 积分兑换为 ¥${(totalPoints / 100).toStringAsFixed(2)} 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('兑换')),
        ],
      ),
    );
    if (confirm != true) return;

    final pointsService = ref.read(pointsServiceProvider);
    final earnings = await pointsService.convertPointsToMoney(totalPoints);
    ref.invalidate(affiliateUserProvider);
    ref.invalidate(pointRecordsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('兑换成功！获得 ¥${earnings.toStringAsFixed(2)}')),
      );
    }
  }
}
