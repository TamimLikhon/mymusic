import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stream_provider.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<MusicStreamProvider>();
    final queue = streamProvider.queue;
    final currentIndex = streamProvider.queueIndex;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: AppColors.surfaceHigh.withValues(alpha: 0.85),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedQueue02,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Up Next',
                          style: AppTypography.heading.copyWith(fontSize: 20),
                        ),
                        const Spacer(),
                        if (queue.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              streamProvider.clearQueue();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Clear',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  // Queue List
                  Expanded(
                    child: queue.isEmpty
                        ? Center(
                            child: Text(
                              'Queue is empty',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            scrollController: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: queue.length,
                            onReorder: streamProvider.reorderQueue,
                            itemBuilder: (context, index) {
                              final song = queue[index];
                              final isPlaying = index == currentIndex;
                              return Dismissible(
                                key: ValueKey('${song.videoId}_$index'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                onDismissed: (_) {
                                  streamProvider.removeFromQueue(index);
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 4,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: song.thumbUrl != null
                                        ? Image.network(
                                            song.thumbUrl!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 48,
                                            height: 48,
                                            color: AppColors.surfaceBorder,
                                            child: const Icon(Icons.music_note, color: AppColors.textSecondary),
                                          ),
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isPlaying
                                          ? const Color(0xFF9D97FF)
                                          : AppColors.textPrimary,
                                      fontWeight: isPlaying
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    song.artists,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption,
                                  ),
                                  trailing: isPlaying
                                      ? const Icon(
                                          Icons.bar_chart_rounded,
                                          color: Color(0xFF6C63FF),
                                        )
                                      : const Icon(
                                          Icons.drag_handle_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                  onTap: () {
                                    streamProvider.playSong(song, index, replaceQueue: false);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
