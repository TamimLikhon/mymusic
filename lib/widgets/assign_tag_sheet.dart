import 'dart:ui';
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
      barrierColor: Colors.black.withValues(alpha: 0.65),
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

  Future<void> _assignToTag(String tagId, bool isCurrentlyAssigned) async {
    final tagProvider = context.read<TagProvider>();
    if (isCurrentlyAssigned) {
      await tagProvider.removeSongFromTag(widget.songId);
      if (mounted) {
        setState(() => _currentTagId = null);
      }
    } else {
      await tagProvider.assignSongToTag(widget.songId, tagId);
      if (mounted) {
        setState(() => _currentTagId = tagId);
      }
    }
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppColors.primary.toARGB32();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AlertDialog(
              backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.glassBorderStrong, width: 1),
              ),
              title: Text('New Tag', style: AppTypography.heading),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Tag name (e.g. Chill, Gym, Coding)',
                      hintStyle: AppTypography.caption,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildColorPicker(
                    selectedColor,
                    (c) => setDialogState(() => selectedColor = c),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final trimmed = nameController.text.trim();
                    if (trimmed.isNotEmpty) {
                      final tagProvider = context.read<TagProvider>();
                      await tagProvider.createTag(trimmed, selectedColor);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: Text(
                    'Create',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(int selectedColor, ValueChanged<int> onColorSelected) {
    final colors = [
      AppColors.primary.toARGB32(),
      AppColors.secondary.toARGB32(),
      AppColors.green.toARGB32(),
      const Color(0xFFE85D75).toARGB32(),
      const Color(0xFF7B68EE).toARGB32(),
      const Color(0xFF00CED1).toARGB32(),
      const Color(0xFFFF69B4).toARGB32(),
      const Color(0xFF98FB98).toARGB32(),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(color).withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.glassBorderStrong, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(top: 14, bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: GlassCard.card(radius: 12),
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedTag01,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assign to Tag', style: AppTypography.heading),
                          const SizedBox(height: 2),
                          Text(
                            widget.songTitle,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCreateTagDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: GlassCard.card(radius: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'New Tag',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.glassBorder),
              // Content
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
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
                                width: 68,
                                height: 68,
                                decoration: GlassCard.card(radius: 20),
                                child: const Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedTag01,
                                    size: 32,
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('No tags yet', style: AppTypography.heading),
                              const SizedBox(height: 6),
                              Text(
                                'Tap "New Tag" above to create your first vibe tag',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        itemCount: tagProvider.tags.length,
                        itemBuilder: (context, index) {
                          final tag = tagProvider.tags[index];
                          final isAssigned = _currentTagId == tag.id;
                          final tagColor = Color(tag.color);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: () => _assignToTag(tag.id, isAssigned),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: isAssigned
                                    ? BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            tagColor.withValues(alpha: 0.85),
                                            Color.lerp(
                                              tagColor,
                                              AppColors.accent,
                                              0.4,
                                            )!.withValues(alpha: 0.85),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: tagColor.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      )
                                    : GlassCard.card(radius: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isAssigned
                                            ? Colors.white.withValues(alpha: 0.22)
                                            : tagColor.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isAssigned
                                              ? Colors.white.withValues(alpha: 0.5)
                                              : tagColor.withValues(alpha: 0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: HugeIcon(
                                          icon: isAssigned
                                              ? HugeIcons.strokeRoundedCheckmarkCircle01
                                              : HugeIcons.strokeRoundedTag01,
                                          color: isAssigned
                                              ? Colors.white
                                              : tagColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tag.name,
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isAssigned
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isAssigned
                                                ? 'Assigned • Tap to remove'
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
                                          : HugeIcons.strokeRoundedAddCircleHalfDot,
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
        ),
      ),
    );
  }
}
