import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/service/greeting_service_provider.dart';

class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final greeting = ref.read(greetingServiceProvider).generate();
    final meditation = _getMeditation();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              '离线模式',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              meditation,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '此刻的宁静',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '没有新消息打扰\n世界暂时与你无关',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '联网后自动刷新',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMeditation() {
    final meditations = [
      '深呼吸，感受此刻的平静',
      '暂时的断联，是给心灵的礼物',
      '听听窗外的声音，世界依然美好',
      '放下手机，看看身边的人',
      '闭上眼睛，给自己一分钟',
      '没有急事需要处理，此刻只需呼吸',
      '断网的时光，是属于自己的时光',
    ];
    return meditations[Random().nextInt(meditations.length)];
  }
}
