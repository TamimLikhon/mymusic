import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
import '../../providers/tag_provider.dart';

class AllTagsPage extends StatelessWidget {
  const AllTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer(),
          ),
        ),
        title: Text('Tags', style: AppTypography.heading),
      ),
      body: Consumer<TagProvider>(
        builder: (context, tagProvider, _) {
          if (tagProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (tagProvider.tags.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildGrid(context, tagProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTagDialog(context),
        child: const Icon(Icons.add),
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
              width: 90,
              height: 90,
              decoration: Neumorphic.raisedCircle(),
              child: const Icon(Icons.label_off_rounded, size: 40, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 22),
            Text(
              'No tags yet',
              style: AppTypography.heading.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              'Create tags to organize your music',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => _showCreateTagDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: Neumorphic.raisedAccent(
                  radius: 26,
                  accent: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Create Tag',
                      style: AppTypography.body.copyWith(
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

  Widget _buildGrid(BuildContext context, TagProvider tagProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: tagProvider.tags.length,
      itemBuilder: (context, index) {
        final tag = tagProvider.tags[index];
        final songCount = tagProvider.songCounts[tag.id] ?? 0;
        final tagColor = Color(tag.color);

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/tag/${tag.id}'),
          onLongPress: () => _showTagOptions(context, tag.id, tag.name, tag.color),
          child: Container(
            decoration: Neumorphic.raised(radius: 18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: tagColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.9),
                          blurRadius: 6,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.label_rounded, color: tagColor, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    tag.name,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.music_note_rounded, size: 12, color: tagColor),
                      const SizedBox(width: 4),
                      Text(
                        '$songCount songs',
                        style: AppTypography.caption.copyWith(
                          color: tagColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTagOptions(BuildContext context, String tagId, String tagName, int tagColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(tagColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.label, color: Color(tagColor), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tagName,
                        style: AppTypography.body.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.amber),
                title: Text('Edit Tag', style: AppTypography.body.copyWith(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTagDialog(context, tagId, tagName, tagColor);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.burntOrange),
                title: Text(
                  'Delete Tag',
                  style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.burntOrange),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteTag(context, tagId, tagName);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppColors.amber.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('New Tag', style: AppTypography.heading.copyWith(fontSize: 12)),
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
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.amber),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildColorPicker(selectedColor, (color) {
                  setState(() => selectedColor = color);
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTypography.caption),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<TagProvider>().createTag(nameController.text, selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: Text('Create', style: AppTypography.body.copyWith(color: AppColors.amber)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, String tagId, String currentName, int currentColor) {
    final nameController = TextEditingController(text: currentName);
    int selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Edit Tag', style: AppTypography.heading.copyWith(fontSize: 12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Tag name',
                    hintStyle: AppTypography.caption,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.amber),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildColorPicker(selectedColor, (color) {
                  setState(() => selectedColor = color);
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTypography.caption),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context.read<TagProvider>().updateTag(tagId, nameController.text, selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save', style: AppTypography.body.copyWith(color: AppColors.amber)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColorPicker(int selectedColor, ValueChanged<int> onColorSelected) {
    final colors = [
      AppColors.amber.toARGB32(),
      AppColors.burntOrange.toARGB32(),
      AppColors.neonGreen.toARGB32(),
      const Color(0xFFE85D75).toARGB32(),
      const Color(0xFF7B68EE).toARGB32(),
      const Color(0xFF00CED1).toARGB32(),
      const Color(0xFFFF69B4).toARGB32(),
      const Color(0xFF98FB98).toARGB32(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: AppTypography.caption),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = color == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 8)]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
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
        backgroundColor: AppColors.surface,
        title: Text('Delete Tag', style: AppTypography.heading.copyWith(fontSize: 12)),
        content: Text(
          'Delete "$tagName"? Songs in this tag will not be deleted.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.caption),
          ),
          TextButton(
            onPressed: () {
              context.read<TagProvider>().deleteTag(tagId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: AppTypography.body.copyWith(color: AppColors.burntOrange)),
          ),
        ],
      ),
    );
  }
}
