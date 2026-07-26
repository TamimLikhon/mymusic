import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
import '../../providers/tag_provider.dart';

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
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Assign to Tag',
                  style: AppTypography.heading.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.songTitle,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                          const Icon(Icons.label_off, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('No tags available', style: AppTypography.caption),
                          const SizedBox(height: 8),
                          Text(
                            'Create a tag first',
                            style: AppTypography.caption.copyWith(fontSize: 11),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: GestureDetector(
                          onTap: () => _assignToTag(tag.id, isAssigned),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: isAssigned
                                ? Neumorphic.raisedAccent(
                                    radius: 14, accent: AppColors.primary)
                                : Neumorphic.raised(radius: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: isAssigned
                                      ? Neumorphic.raisedCircle()
                                      : BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tagColor.withValues(alpha: 0.12),
                                        ),
                                  child: Icon(
                                    isAssigned ? Icons.check_circle_rounded : Icons.label_rounded,
                                    color: isAssigned ? AppColors.primary : tagColor,
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
                                        style: AppTypography.body.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isAssigned
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        isAssigned ? 'Currently assigned' : 'Tap to assign',
                                        style: AppTypography.caption.copyWith(
                                          color: isAssigned
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isAssigned
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isAssigned ? Colors.white : AppColors.textDisabled,
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
        ],
      ),
    );
  }

  Future<void> _assignToTag(String tagId, bool isCurrentlyAssigned) async {
    final tagProvider = context.read<TagProvider>();

    if (isCurrentlyAssigned) {
      // Unassign from current tag
      await tagProvider.removeSongFromTag(widget.songId);
      setState(() => _currentTagId = null);
    } else {
      // If already assigned to another tag, remove first
      if (_currentTagId != null) {
        await tagProvider.removeSongFromTag(widget.songId);
      }
      // Assign to new tag
      await tagProvider.assignSongToTag(widget.songId, tagId);
      setState(() => _currentTagId = tagId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyAssigned ? 'Removed from tag' : 'Assigned to tag',
            style: AppTypography.body.copyWith(fontSize: 13),
          ),
          backgroundColor: isCurrentlyAssigned ? AppColors.secondary : AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
