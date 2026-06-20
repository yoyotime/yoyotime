import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/model/affiliate_models.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/product_card.dart';

class AffiliateHomeScreen extends ConsumerWidget {
  const AffiliateHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final userAsync = ref.watch(affiliateUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('好物推荐'),
        actions: [
          userAsync.whenOrNull(
                data: (user) => user.isRegistered
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.monetization_on_outlined),
                          tooltip: '我的积分',
                          onPressed: () => context.push('/affiliate/points'),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.person_add_outlined),
                          tooltip: '注册赚积分',
                          onPressed: () => context.push('/affiliate/register'),
                        ),
                      ),
              ) ??
              const SizedBox.shrink(),
          if (userAsync.whenOrNull(data: (u) => u.isRegistered) == true)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: '发布商品',
              onPressed: () => context.push('/affiliate/publish'),
            ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => _ProductGrid(products: products),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('还没有商品', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '共 ${products.length} 件好物',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const Spacer(),
                Text(
                  '点击赚积分',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  showPublisher: true,
                  onTap: () => context.push('/affiliate/product/${product.id}'),
                );
              },
              childCount: products.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
