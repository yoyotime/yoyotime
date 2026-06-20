import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/affiliate_storage.dart';
import '../../../domain/model/affiliate_models.dart';
import '../../../shared/widgets/voice_input_dialog.dart';
import '../providers/affiliate_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.card_giftcard, size: 80, color: Colors.amber[600]),
            const SizedBox(height: 24),
            Text(
              '注册会员 · 赚取好康',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '注册后可以发布商品、赚取积分、兑换现金',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _benefitRow(Icons.touch_app, '点击商品赚积分'),
                    const Divider(),
                    _benefitRow(Icons.monetization_on, '积分可兑换现金'),
                    const Divider(),
                    _benefitRow(Icons.add_circle, '发布商品赚佣金'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: '昵称（可选）',
                hintText: '输入你的昵称',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: () async {
                    final result = await showVoiceInputDialog(context, hint: '说出你的昵称');
                    if (result != null && result.isNotEmpty) {
                      _nameCtrl.text = result;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _register,
                child: const Text('立即注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final storage = ref.read(affiliateStorageProvider);

    final existingUser = await storage.getUser();
    final newUser = AffiliateUser(
      id: existingUser.id,
      nickname: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
      isRegistered: true,
      totalPoints: 50,
    );

    await storage.saveUser(newUser);
    ref.invalidate(affiliateUserProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功！赠送 50 积分')),
      );
      context.pop();
    }
  }
}
