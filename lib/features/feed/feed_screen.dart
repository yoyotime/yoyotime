import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../shared/models/content.dart';
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
            onPressed: () => controller.load(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: _buildBody(context, state, controller),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedState state,
    FeedController controller,
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
        if (index == 0) return _dateHeader(context, state);
        final item = state.items[index - 1];
        return ContentCard(
          item: item,
          onTap: () => context.push('/reader/${item.id}'),
          onFeedback: (action) => controller.actOnContent(item, action),
        );
      },
    );
  }

  Widget _dateHeader(BuildContext context, FeedState state) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 6) {
      greeting = '夜深了';
    } else if (hour < 12) {
      greeting = '早安';
    } else if (hour < 18) {
      greeting = '午安';
    } else {
      greeting = '晚安';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            state.lastUpdated != null
                ? '更新于 ${timeago.format(state.lastUpdated!, locale: 'zh')}'
                : '为您精选 ${state.items.length} 条',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
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
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.wb_cloudy_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            state.error ?? '今天的内容在路上',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.tonal(
            onPressed: () => controller.load(),
            child: const Text('再试一次'),
          ),
        ),
      ],
    );
  }
}
