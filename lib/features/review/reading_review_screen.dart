import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repository/repository_providers.dart';
import '../../domain/model/content_item.dart';
import '../../shared/widgets/content_card.dart';
import '../feed/audio_player_controller.dart';

class ReadingReviewScreen extends ConsumerStatefulWidget {
  const ReadingReviewScreen({super.key});

  @override
  ConsumerState<ReadingReviewScreen> createState() => _ReadingReviewScreenState();
}

class _ReadingReviewScreenState extends ConsumerState<ReadingReviewScreen> {
  List<ContentItem> _weekItems = [];
  int _totalRead = 0;
  int _uniqueSources = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(contentRepositoryProvider);
    final readIds = await repo.getWeeklyReadIds();
    final cached = await repo.getCachedContents();

    final weekItems = cached.where((item) => readIds.contains(item.id)).toList();
    final sources = weekItems.map((item) => item.sourceName).toSet();

    setState(() {
      _weekItems = weekItems;
      _totalRead = readIds.length;
      _uniqueSources = sources.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读回顾'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(theme),
                const SizedBox(height: 24),
                Text(
                  '本周读过',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_weekItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '本周还没有阅读记录',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(_weekItems.length, (index) {
                    final item = _weekItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ContentCard(
                        item: item,
                        onTap: () => context.push('/reader/${item.id}'),
                        onPlay: () {
                          ref.read(audioPlayerProvider.notifier).playAll(
                            _weekItems,
                            startIndex: index,
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '本周阅读概览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(theme, '$_totalRead', '篇'),
              Container(width: 1, height: 40, color: theme.colorScheme.outline.withOpacity(0.3)),
              _buildStat(theme, '$_uniqueSources', '个来源'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getSummaryText(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  String _getSummaryText() {
    if (_totalRead == 0) return '开始阅读，记录你的每周足迹';
    if (_totalRead < 5) return '继续保持，每天读一点';
    if (_totalRead < 10) return '阅读量不错，保持好奇心';
    return '本周阅读达人，知识面很广';
  }
}
