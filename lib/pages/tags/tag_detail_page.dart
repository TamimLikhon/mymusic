import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/tag_provider.dart';
import '../../providers/audio_provider.dart';
import '../../data/database/app_database.dart';
import '../../widgets/song_tile.dart';
import '../../core/utils/duration_formatter.dart';

class TagDetailPage extends StatefulWidget {
  final String tagId;
  const TagDetailPage({super.key, required this.tagId});

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await context.read<TagProvider>().getSongsForTag(widget.tagId);
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  int get _totalDuration => _songs.fold(0, (sum, song) => sum + song.duration);

  @override
  Widget build(BuildContext context) {
    final tagProvider = context.watch<TagProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final tagOrNull = tagProvider.tags.cast<Tag?>().firstWhere(
      (t) => t?.id == widget.tagId,
      orElse: () => null,
    );

    if (tagOrNull == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tag = tagOrNull;
    final tagColor = Color(tag.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
          : CustomScrollView(
              slivers: [
                // ── Immersive Header ─────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 220,
                  pinned: true,
                  leading: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: GlassCard.card(radius: 10),
                      child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 20, color: AppColors.textPrimary),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _showEditTagDialog(context, tag),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: GlassCard.card(radius: 10),
                          child: const HugeIcon(icon: HugeIcons.strokeRoundedEdit01,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Gradient background seeded from tag color
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                tagColor.withValues(alpha: 0.40),
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                        // Content
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: tagColor.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: tagColor.withValues(alpha: 0.5), width: 1.5),
                                  ),
                                  child: HugeIcon(icon: HugeIcons.strokeRoundedTag01, color: tagColor, size: 36),
                                ),
                                const SizedBox(height: 12),
                                Text(tag.name, style: AppTypography.hero),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    HugeIcon(icon: HugeIcons.strokeRoundedMusicNote01, size: 13, color: tagColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_songs.length} songs',
                                      style: AppTypography.caption.copyWith(color: tagColor),
                                    ),
                                    if (_songs.isNotEmpty) ...[
                                      const SizedBox(width: 16),
                                      HugeIcon(icon: HugeIcons.strokeRoundedTimer02, size: 13, color: tagColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatDuration(_totalDuration),
                                        style: AppTypography.caption.copyWith(color: tagColor),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Action Buttons ───────────────────────────────────────────
                if (_songs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Play All',
                              icon: HugeIcons.strokeRoundedPlay,
                              color: tagColor,
                              onPressed: () =>
                                  audioProvider.playFromTag(widget.tagId, _songs),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: 'Shuffle',
                              icon: HugeIcons.strokeRoundedShuffle,
                              color: AppColors.surfaceHigh,
                              textColor: AppColors.textPrimary,
                              onPressed: () =>
                                  audioProvider.shuffleFromTag(widget.tagId, _songs),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Song List ────────────────────────────────────────────────
                if (_songs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedMusicNote01,
                              size: 52, color: tagColor.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text('No songs in this tag', style: AppTypography.heading),
                          const SizedBox(height: 8),
                          Text(
                            'Long-press any song and choose "Assign to tag"',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = _songs[index];
                        return Dismissible(
                          key: Key(song.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const HugeIcon(icon: HugeIcons.strokeRoundedRemoveCircle,
                                color: AppColors.secondary),
                          ),
                          confirmDismiss: (direction) => _confirmRemove(context, song),
                          onDismissed: (_) {
                            context.read<TagProvider>().removeSongFromTag(song.id);
                            setState(() => _songs.removeAt(index));
                          },
                          child: SongTile(
                            song: song,
                            index: index,
                            isPlaying: audioProvider.currentSong?.id == song.id,
                            onTap: () => audioProvider.playFromTag(
                                widget.tagId, _songs,
                                startIndex: index),
                            onLongPress: () => _showSongOptions(context, song),
                          ),
                        );
                      },
                      childCount: _songs.length,
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context, Song song) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Song', style: AppTypography.heading),
        content: Text(
          'Remove "${song.title}" from this tag?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove',
                style: AppTypography.body.copyWith(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(song.title,
                  style: AppTypography.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: GlassCard.card(radius: 12),
                child: const HugeIcon(icon: HugeIcons.strokeRoundedRemoveCircle,
                    color: AppColors.secondary, size: 20),
              ),
              title: Text('Remove from tag',
                  style: AppTypography.body.copyWith(color: AppColors.secondary)),
              onTap: () {
                Navigator.pop(context);
                context.read<TagProvider>().removeSongFromTag(song.id);
                _loadSongs();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    final nameController = TextEditingController(text: tag.name);
    int selectedColor = tag.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              _buildColorPicker(selectedColor, (c) => setState(() => selectedColor = c)),
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
                      .updateTag(tag.id, nameController.text, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: Text('Save',
                  style: AppTypography.body.copyWith(color: AppColors.primary)),
            ),
          ],
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
            child: isSelected ? const HugeIcon(icon: HugeIcons.strokeRoundedTick01, size: 16, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, size: 20, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
