import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';
import '../providers/affiliate_providers.dart';
import '../services/points_service.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final userAsync = ref.watch(affiliateUserProvider);
    final theme = Theme.of(context);

    return productsAsync.when(
      data: (products) {
        final product = products.where((p) => p.id == productId).firstOrNull;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('商品不存在')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(product.title)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[200],
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 64),
                        )
                      : const Icon(Icons.image_outlined, size: 64),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '¥${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '点击得 ${product.pointsOnClick} 积分',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (product.commission != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '推广佣金: ¥${product.commission!.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ],
                      if (product.publisherName != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16),
                            const SizedBox(width: 4),
                            Text('发布者: ${product.publisherName}'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('查看商品详情'),
                          onPressed: () => _onBuy(context, ref, product, userAsync),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('加载失败: $e'))),
    );
  }

  Future<void> _onBuy(
    BuildContext context,
    WidgetRef ref,
    Product product,
    AsyncValue<AffiliateUser> userAsync,
  ) async {
    final isRegistered = userAsync.whenOrNull(data: (u) => u.isRegistered) ?? false;

    try {
      await launchUrl(Uri.parse(product.affiliateUrl), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开链接')),
        );
      }
      return;
    }

    if (isRegistered) {
      final pointsService = ref.read(pointsServiceProvider);
      final points = await pointsService.earnClickPoints(product);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获得 $points 积分！继续赚积分可兑换现金')),
        );
      }
    }

    if (product.commission != null && context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('购买成功？'),
          content: Text(
            isRegistered
                ? '如果在淘宝完成购买，您将获得 ¥${product.commission!.toStringAsFixed(2)} 佣金'
                : '注册用户可赚取积分和佣金，快去注册吧',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
    }
  }
}
