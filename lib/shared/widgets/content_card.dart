import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/content.dart';
import '../utils/html_utils.dart';

class ContentCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final ValueChanged<FeedbackAction>? onFeedback;
  final VoidCallback? onPlay;

  const ContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFeedback,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.sourceName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeago.format(item.publishedAt, locale: 'zh'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                stripHtml(item.summary),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniChip(
                    icon: Icons.schedule_outlined,
                    label: '${item.estimatedReadTimeMinutes} 分钟',
                  ),
                  const SizedBox(width: 8),
                  for (final topic in item.topics.take(2))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _MiniChip(label: '#$topic'),
                    ),
                  const Spacer(),
                  if (onPlay != null)
                    _IconButton(
                      icon: Icons.play_circle_outline,
                      onTap: onPlay!,
                      tooltip: '播放',
                    ),
                  _FeedbackIcons(onFeedback: onFeedback),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _MiniChip({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: theme.colorScheme.outline),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackIcons extends StatelessWidget {
  final ValueChanged<FeedbackAction>? onFeedback;
  const _FeedbackIcons({this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconButton(
          icon: Icons.bookmark_border,
          onTap: () => onFeedback?.call(FeedbackAction.bookmark),
          tooltip: '收藏',
        ),
        _IconButton(
          icon: Icons.thumb_down_alt_outlined,
          onTap: () => onFeedback?.call(FeedbackAction.dislike),
          tooltip: '不喜欢',
          color: theme.colorScheme.outline,
        ),
        _IconButton(
          icon: Icons.delete_outline,
          onTap: () => onFeedback?.call(FeedbackAction.delete),
          tooltip: '不想看到',
          color: theme.colorScheme.outline,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: color,
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
