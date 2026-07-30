import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/tag_provider.dart';

class AllTagsPage extends StatelessWidget {
  const AllTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<TagProvider>(
        builder: (context, tagProvider, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Library', style: AppTypography.display.copyWith(fontSize: 28)),
                        ),
                        GestureDetector(
                          onTap: () => _showCreateTagDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: GlassCard.accent(radius: 20, accentColor: AppColors.primary),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'New Tag',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (tagProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  ),
                )
              else if (tagProvider.tags.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text('YOUR TAGS', style: AppTypography.overline),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tag = tagProvider.tags[index];
                        final songCount = tagProvider.songCounts[tag.id] ?? 0;
                        final tagColor = Color(tag.color);
                        return _buildTagCard(context, tag.id, tag.name, tag.color, tagColor, songCount);
                      },
                      childCount: tagProvider.tags.length,
                    ),
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTagCard(BuildContext context, String tagId, String tagName,
      int tagColorInt, Color tagColor, int songCount) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/tag/$tagId'),
      onLongPress: () => _showTagOptions(context, tagId, tagName, tagColorInt),
      child: Container(
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tagColor.withValues(alpha: 0.25), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(icon: HugeIcons.strokeRoundedTag01, color: tagColor, size: 22),
              ),
              const Spacer(),
              Text(
                tagName,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedMusicNote01, size: 11, color: tagColor),
                  const SizedBox(width: 4),
                  Text(
                    '$songCount songs',
                    style: AppTypography.caption.copyWith(
                      color: tagColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedTag01, size: 46, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            Text('No tags yet', style: AppTypography.heading.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Create tags to organize your music into playlists and moods.',
              style: AppTypography.caption.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _showCreateTagDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: GlassCard.accent(radius: 28, accentColor: AppColors.primary),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Create Tag',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagOptions(BuildContext context, String tagId, String tagName, int tagColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(tagColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedTag01, color: Color(tagColor), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tagName, style: AppTypography.heading),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: GlassCard.card(radius: 12),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedEdit01, color: AppColors.primary, size: 20),
                ),
                title: Text('Edit Tag', style: AppTypography.body),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTagDialog(context, tagId, tagName, tagColor);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: GlassCard.card(radius: 12),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: AppColors.secondary, size: 20),
                ),
                title: Text(
                  'Delete Tag',
                  style: AppTypography.body.copyWith(color: AppColors.secondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteTag(context, tagId, tagName);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppColors.primary.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('New Tag', style: AppTypography.heading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tag name',
                    hintStyle: AppTypography.caption,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildColorPicker(selectedColor, (color) {
                  setState(() => selectedColor = color);
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<TagProvider>().createTag(nameController.text, selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: Text('Create',
                    style: AppTypography.body.copyWith(color: AppColors.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditTagDialog(
      BuildContext context, String tagId, String currentName, int currentColor) {
    final nameController = TextEditingController(text: currentName);
    int selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Tag', style: AppTypography.heading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Tag name',
                    hintStyle: AppTypography.caption,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildColorPicker(selectedColor, (color) {
                  setState(() => selectedColor = color);
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context
                        .read<TagProvider>()
                        .updateTag(tagId, nameController.text, selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save',
                    style: AppTypography.body.copyWith(color: AppColors.primary)),
              ),
            ],
          );
        },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a color', style: AppTypography.caption),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((color) {
            final isSelected = color == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 10)]
                      : null,
                ),
                child: isSelected
                    ? const HugeIcon(icon: HugeIcons.strokeRoundedTick01, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDeleteTag(BuildContext context, String tagId, String tagName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Tag', style: AppTypography.heading),
        content: Text(
          'Delete "$tagName"? Songs won\'t be deleted.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<TagProvider>().deleteTag(tagId);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: AppTypography.body.copyWith(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}
