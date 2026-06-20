import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/pdd/pdd_api.dart';
import '../../../core/pdd/pdd_service.dart';
import '../../../core/tbk/tbk_api.dart';
import '../../../core/tbk/tbk_service.dart';
import '../../../domain/model/affiliate_models.dart';
import '../providers/affiliate_providers.dart';
import '../widgets/product_card.dart';

class AffiliateHomeScreen extends ConsumerStatefulWidget {
  const AffiliateHomeScreen({super.key});

  @override
  ConsumerState<AffiliateHomeScreen> createState() => _AffiliateHomeScreenState();
}

class _AffiliateHomeScreenState extends ConsumerState<AffiliateHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _usePdd = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final userAsync = ref.watch(affiliateUserProvider);
    final tbkConfigured = ref.watch(tbkConfiguredProvider);
    final pddConfigured = ref.watch(pddConfiguredProvider);
    final searchResults = _usePdd
        ? ref.watch(pddSearchResultsProvider(_searchQuery)) as AsyncValue<List<dynamic>>
        : ref.watch(tbkSearchResultsProvider(_searchQuery)) as AsyncValue<List<dynamic>>;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
              children: [
                _SourceChip(
                  label: '淘宝',
                  selected: !_usePdd,
                  onTap: () => setState(() => _usePdd = false),
                ),
                const SizedBox(width: 8),
                _SourceChip(
                  label: '拼多多',
                  selected: _usePdd,
                  onTap: () => setState(() => _usePdd = true),
                ),
              ],
            ),
          ),
          _SearchBar(
            controller: _searchCtrl,
            hint: _usePdd ? '搜索拼多多商品…' : '搜索淘宝商品…',
            onSearch: (q) {
              setState(() => _searchQuery = q);
            },
          ),
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(searchResults, _usePdd ? pddConfigured : tbkConfigured)
                : productsAsync.when(
                    data: (products) => _buildDefaultView(products, tbkConfigured, pddConfigured),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('加载失败: $e')),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultView(
    List<Product> products,
    AsyncValue<bool> tbkConfigured,
    AsyncValue<bool> pddConfigured,
  ) {
    if (products.isNotEmpty) return _ProductGrid(products: products);
    return tbkConfigured.when(
      data: (tbkOk) => pddConfigured.when(
        data: (pddOk) {
          if (tbkOk || pddOk) {
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('请先配置商品来源'),
                const SizedBox(height: 4),
                Text(
                  '需要淘宝客或拼多多 API 密钥才能搜索商品',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.push('/affiliate/settings'),
                  child: const Text('去配置'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<dynamic>> searchResults,
    AsyncValue<bool> configured,
  ) {
    final sourceName = _usePdd ? '拼多多' : '淘宝客';
    return configured.when(
      data: (configured) {
        if (!configured) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('请先配置 $sourceName API'),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => context.push('/affiliate/settings'),
                  child: const Text('去配置'),
                ),
              ],
            ),
          );
        }
        return searchResults.when(
          data: (results) {
            if (results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('未找到相关商品', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              itemBuilder: (_, i) => _usePdd
                  ? _PddResultCard(result: results[i] as PddApiResult)
                  : _TbkResultCard(result: results[i] as TbkApiResult),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('搜索失败: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SourceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final String hint;

  const _SearchBar({required this.controller, required this.onSearch, this.hint = '搜索淘宝商品…'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: controller,
          decoration: InputDecoration(
            hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) onSearch(v.trim());
        },
      ),
    );
  }
}

class _TbkResultCard extends StatelessWidget {
  final TbkApiResult result;
  const _TbkResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clickUrl = result.couponUrl ?? result.clickUrl ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: clickUrl.isNotEmpty
            ? () => launchUrl(Uri.parse(clickUrl), mode: LaunchMode.externalApplication)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[100],
                  child: result.imageUrl != null
                      ? Image.network(
                          result.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 32),
                        )
                      : const Icon(Icons.image_outlined, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '¥${result.price}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (result.reservePrice != null && result.reservePrice != result.price) ...[
                          const SizedBox(width: 6),
                          Text(
                            '¥${result.reservePrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (result.commissionRate != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${result.commissionRate}%',
                              style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (result.volume > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '已售 ${_formatVolume(result.volume)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatVolume(int v) {
    if (v >= 10000) return '${(v / 10000).toStringAsFixed(1)}万';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}千';
    return v.toString();
  }
}

class _PddResultCard extends StatelessWidget {
  final PddApiResult result;
  const _PddResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[100],
                child: result.imageUrl != null
                    ? Image.network(
                        result.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 32),
                      )
                    : const Icon(Icons.image_outlined, size: 32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '¥${result.priceYuan.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (result.groupPriceYuan > 0 && result.groupPriceYuan < result.priceYuan) ...[
                        const SizedBox(width: 6),
                        Text(
                          '拼团 ¥${result.groupPriceYuan.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11, color: Colors.green[700]),
                        ),
                      ],
                      if (result.commissionRatePercent > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${result.commissionRatePercent.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (result.salesTip != null && result.salesTip!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      result.salesTip!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                  if (result.hasCoupon && result.couponDiscount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '券 ¥${(result.couponDiscount / 100).toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10, color: Colors.red[800]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
