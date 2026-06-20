import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';
import '../providers/affiliate_providers.dart';

class PublishProductScreen extends ConsumerStatefulWidget {
  const PublishProductScreen({super.key});

  @override
  ConsumerState<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends ConsumerState<PublishProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _affiliateUrlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  int _pointsOnClick = 10;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _affiliateUrlCtrl.dispose();
    _imageUrlCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(affiliateUserProvider);
    final isRegistered = userAsync.whenOrNull(data: (u) => u.isRegistered) ?? false;

    if (!isRegistered) {
      return Scaffold(
        appBar: AppBar(title: const Text('发布商品')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('注册后才可发布商品'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/affiliate/register'),
                child: const Text('去注册'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('发布商品')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: '商品名称',
                  hintText: '例如：静音蓝牙耳机',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '请输入商品名称' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: '商品图片链接（可选）',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '商品描述',
                  hintText: '简单介绍你的商品…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '价格 (¥)',
                        border: OutlineInputBorder(),
                        prefixText: '¥ ',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '请输入价格';
                        if (double.tryParse(v) == null) return '请输入有效数字';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _commissionCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '佣金 (¥)',
                        border: OutlineInputBorder(),
                        prefixText: '¥ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _affiliateUrlCtrl,
                decoration: const InputDecoration(
                  labelText: '推广链接',
                  hintText: 'https://s.click.taobao.com/...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '请输入推广链接' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('点击可得积分:'),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: Slider(
                      value: _pointsOnClick.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '$_pointsOnClick',
                      onChanged: (v) => setState(() => _pointsOnClick = v.round()),
                    ),
                  ),
                  Text('$_pointsOnClick'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('发布商品'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await ref.read(affiliateStorageProvider).getUser();
    final product = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      imageUrl: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      affiliateUrl: _affiliateUrlCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      commission: _commissionCtrl.text.trim().isEmpty ? null : double.tryParse(_commissionCtrl.text.trim()),
      publisherId: user.id,
      publisherName: user.nickname ?? '匿名',
      pointsOnClick: _pointsOnClick,
      source: '用户发布',
    );

    await ref.read(affiliateStorageProvider).addProduct(product);

    ref.invalidate(productsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('商品发布成功！')),
      );
      context.pop();
    }
  }
}
