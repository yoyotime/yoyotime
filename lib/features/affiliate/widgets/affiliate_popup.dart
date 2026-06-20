import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/affiliate_providers.dart';

class AffiliatePopup extends ConsumerWidget {
  const AffiliatePopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(popupVisibleProvider);
    if (!visible) return const SizedBox.shrink();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    '发现隐藏宝库',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击商品赚积分，积分可兑换现金',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => ref.read(popupVisibleProvider.notifier).hide(),
                        child: const Text('暂时不要'),
                      ),
                      FilledButton.icon(
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text('去看看'),
                        onPressed: () {
                          ref.read(popupVisibleProvider.notifier).hide();
                          context.push('/affiliate');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
