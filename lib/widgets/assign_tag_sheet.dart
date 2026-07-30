import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/glass_card.dart';
import '../providers/tag_provider.dart';

class AssignTagSheet extends StatefulWidget {
  final String songId;
  final String songTitle;

  const AssignTagSheet({
    super.key,
    required this.songId,
    required this.songTitle,
  });

  static Future<void> show(BuildContext context, String songId, String songTitle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignTagSheet(songId: songId, songTitle: songTitle),
    );
  }

  @override
  State<AssignTagSheet> createState() => _AssignTagSheetState();
}

class _AssignTagSheetState extends State<AssignTagSheet> {
  String? _currentTagId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentTag();
  }

  Future<void> _loadCurrentTag() async {
    final tag = await context.read<TagProvider>().getTagForSong(widget.songId);
    if (mounted) {
      setState(() {
        _currentTagId = tag?.id;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: GlassCard.card(radius: 10),
                      child: const HugeIcon(icon: HugeIcons.strokeRoundedTag01,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assign to Tag', style: AppTypography.heading),
                          Text(
                            widget.songTitle,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          // Content
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            )
          else
            Expanded(
              child: Consumer<TagProvider>(
                builder: (context, tagProvider, _) {
                  if (tagProvider.tags.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: GlassCard.card(radius: 18),
                            child: const HugeIcon(icon: HugeIcons.strokeRoundedTag01,
                                size: 30, color: AppColors.textDisabled),
                          ),
                          const SizedBox(height: 16),
                          Text('No tags yet', style: AppTypography.heading),
                          const SizedBox(height: 6),
                          Text(
                            'Create a tag in the Library tab first',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tagProvider.tags.length,
                    itemBuilder: (context, index) {
                      final tag = tagProvider.tags[index];
                      final isAssigned = _currentTagId == tag.id;
                      final tagColor = Color(tag.color);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: GestureDetector(
                          onTap: () => _assignToTag(tag.id, isAssigned),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: isAssigned
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        Color.lerp(AppColors.primary, AppColors.accent, 0.4)!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  )
                                : GlassCard.card(radius: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isAssigned
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : tagColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: HugeIcon(
                                    icon: isAssigned
                                        ? HugeIcons.strokeRoundedCheckmarkCircle01
                                        : HugeIcons.strokeRoundedTag01,
                                    color: isAssigned ? Colors.white : tagColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tag.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isAssigned
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        isAssigned
                                            ? 'Currently assigned — tap to remove'
                                            : 'Tap to assign',
                                        style: AppTypography.caption.copyWith(
                                          color: isAssigned
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                HugeIcon(
                                  icon: isAssigned
                                      ? HugeIcons.strokeRoundedCheckmarkCircle01
                                      : HugeIcons.strokeRoundedRemoveCircle,
                                  color: isAssigned
                                      ? Colors.white
                                      : AppColors.textDisabled,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _assignToTag(String tagId, bool isCurrentlyAssigned) async {
    final tagProvider = context.read<TagProvider>();

    if (isCurrentlyAssigned) {
      await tagProvider.removeSongFromTag(widget.songId);
      setState(() => _currentTagId = null);
    } else {
      if (_currentTagId != null) {
        await tagProvider.removeSongFromTag(widget.songId);
      }
      await tagProvider.assignSongToTag(widget.songId, tagId);
      setState(() => _currentTagId = tagId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyAssigned ? 'Removed from tag' : 'Added to tag ✓',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
