import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/repository/repository_providers.dart';
import '../../domain/model/content_item.dart';
import '../../shared/widgets/content_card.dart';
import '../feed/feed_controller.dart';
import '../feed/audio_player_controller.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  List<ContentItem> _bookmarks = [];
  List<ContentItem> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(contentRepositoryProvider);
    final bookmarks = await repo.getBookmarkedContents();
    setState(() {
      _bookmarks = bookmarks;
      _filtered = bookmarks;
      _isLoading = false;
    });
  }

  void _filterBookmarks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filtered = _bookmarks;
      } else {
        _filtered = _bookmarks.where((item) {
          return item.title.contains(query) ||
              item.summary.contains(query) ||
              item.topics.any((t) => t.contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏集'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBookmarks,
              decoration: InputDecoration(
                hintText: '搜索收藏...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBookmarks('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.bookmark_border,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? '没有找到相关内容'
                                  : '还没有收藏',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? '试试其他关键词'
                                  : '在阅读文章时点击收藏按钮',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return ContentCard(
                            item: item,
                            onTap: () => context.push('/reader/${item.id}'),
                            onPlay: () {
                              ref.read(audioPlayerProvider.notifier).playAll(
                                _filtered,
                                startIndex: index,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
