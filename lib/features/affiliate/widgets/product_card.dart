import 'package:flutter/material.dart';
import '../../../domain/model/affiliate_models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showPublisher;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showPublisher = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[200],
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderIcon(),
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : _placeholderIcon(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.commission != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '佣金¥${product.commission!.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showPublisher && product.publisherName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            product.publisherName!,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() => const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
      );
}
