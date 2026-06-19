import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/service/greeting_service_provider.dart';
import '../../domain/model/greeting.dart';
import '../../shared/widgets/content_card.dart';
import 'feed_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: _buildBody(context, state, controller, ref),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedState state,
    FeedController controller,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return _emptyState(context, state, controller);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        if (index == 0) return _dateHeader(context, state, ref);
        final item = state.items[index - 1];
        return ContentCard(
          item: item,
          onTap: () => context.push('/reader/${item.id}'),
          onFeedback: (action) => controller.actOnContent(item, action),
        );
      },
    );
  }

  Widget _dateHeader(BuildContext context, FeedState state, WidgetRef ref) {
    final greetingService = ref.read(greetingServiceProvider);
    final greeting = greetingService.generate();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting.text,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            greeting.subText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.lastUpdated != null
                ? '更新于 ${timeago.format(state.lastUpdated!, locale: 'zh')}'
                : '为您精选 ${state.items.length} 条',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
    BuildContext context,
    FeedState state,
    FeedController controller,
  ) {
    final isDone = state.error == '今天的内容看完了，明天见';
    final failedInfo = state.failedSources.isNotEmpty
        ? '\n\n无法连接: ${state.failedSources.join('、')}'
        : '';
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(
          isDone ? Icons.nightlight_round : Icons.wb_cloudy_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            (state.error ?? '今天的内容在路上') + failedInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.tonal(
            onPressed: () => (isDone ? controller.refresh() : controller.load()),
            child: Text(isDone ? '再刷几条' : '再试一次'),
          ),
        ),
      ],
    );
  }
}
