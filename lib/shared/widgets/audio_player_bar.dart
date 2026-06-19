import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/feed/audio_player_controller.dart';

class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final controller = ref.read(audioPlayerProvider.notifier);
    final theme = Theme.of(context);

    if (!playerState.isPlaying && !playerState.isPaused) {
      return const SizedBox.shrink();
    }

    final current = playerState.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  playerState.isPaused ? Icons.play_arrow : Icons.pause,
                  color: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (playerState.isPaused) {
                    controller.resume();
                  } else {
                    controller.pause();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${playerState.currentIndex + 1}/${playerState.queue.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: controller.playPrevious,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: controller.playNext,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.stop,
            ),
          ],
        ),
      ),
    );
  }
}
