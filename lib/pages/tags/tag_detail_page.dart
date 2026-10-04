import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/tag_provider.dart';
import '../../providers/song_provider.dart';
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
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final tag = tagOrNull;
    final tagColor = Color(tag.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Cosmos Ambient Glow Orbs ───────────────────────────────────────
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    tagColor.withValues(alpha: 0.35),
                    tagColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Scroll View ──────────────────────────────────────────────
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // ── Immersive Header ─────────────────────────────────────
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: 240,
                      pinned: true,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: GlassCard.card(radius: 12),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowLeft01,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _showAddSongsSheet(context, tag),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: GlassCard.card(radius: 12),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedAdd01,
                                  size: 18,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () => _showEditTagDialog(context, tag),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: GlassCard.card(radius: 12),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit01,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            tagColor.withValues(alpha: 0.35),
                                            tagColor.withValues(alpha: 0.15),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: tagColor.withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: tagColor.withValues(alpha: 0.3),
                                            blurRadius: 18,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedTag01,
                                          color: tagColor,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tag.name,
                                            style: AppTypography.hero.copyWith(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons.strokeRoundedMusicNote01,
                                                size: 13,
                                                color: tagColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_songs.length} ${_songs.length == 1 ? "song" : "songs"}',
                                                style: AppTypography.caption.copyWith(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (_songs.isNotEmpty) ...[
                                                const SizedBox(width: 12),
                                                Text(
                                                  '•',
                                                  style: AppTypography.caption.copyWith(
                                                    color: AppColors.textDisabled,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                HugeIcon(
                                                  icon: HugeIcons.strokeRoundedTimer02,
                                                  size: 13,
                                                  color: tagColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formatDuration(_totalDuration),
                                                  style: AppTypography.caption.copyWith(
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Action Buttons ───────────────────────────────────────
                    if (_songs.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _GlassTagActionButton(
                                  label: 'Play All',
                                  icon: HugeIcons.strokeRoundedPlay,
                                  isPrimary: true,
                                  accentColor: tagColor,
                                  onPressed: () => audioProvider.playFromTag(
                                    widget.tagId,
                                    _songs,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GlassTagActionButton(
                                  label: 'Shuffle',
                                  icon: HugeIcons.strokeRoundedShuffle,
                                  isPrimary: false,
                                  accentColor: tagColor,
                                  onPressed: () => audioProvider.shuffleFromTag(
                                    widget.tagId,
                                    _songs,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Song List ────────────────────────────────────────────
                    if (_songs.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: GlassCard.card(radius: 24),
                                  child: Center(
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedMusicNote01,
                                      size: 40,
                                      color: tagColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No songs in this tag',
                                  style: AppTypography.heading,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add songs to this tag to build your custom vibe playlist',
                                  style: AppTypography.caption,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: () => _showAddSongsSheet(context, tag),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    decoration: GlassCard.accent(
                                      radius: 20,
                                      accentColor: tagColor,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const HugeIcon(
                                          icon: HugeIcons.strokeRoundedAdd01,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add Songs',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: Colors.white,
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
                                  horizontal: 14,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedRemoveCircle,
                                  color: AppColors.secondary,
                                  size: 22,
                                ),
                              ),
                              confirmDismiss: (_) => _confirmRemove(context, song),
                              onDismissed: (_) {
                                context
                                    .read<TagProvider>()
                                    .removeSongFromTag(song.id);
                                setState(() => _songs.removeAt(index));
                              },
                              child: SongTile(
                                song: song,
                                index: index,
                                isPlaying: audioProvider.currentSong?.id == song.id,
                                onTap: () => audioProvider.playFromTag(
                                  widget.tagId,
                                  _songs,
                                  startIndex: index,
                                ),
                                onLongPress: () => _showSongOptions(context, song),
                              ),
                            );
                          },
                          childCount: _songs.length,
                        ),
                      ),

                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 120),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _showAddSongsSheet(BuildContext context, Tag tag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetContext) => _AddSongsToTagSheet(
        tag: tag,
        onChanged: _loadSongs,
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context, Song song) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.92),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.glassBorderStrong, width: 1),
            ),
            title: Text('Remove Song', style: AppTypography.heading),
            content: Text(
              'Remove "${song.title}" from this tag?',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.glassBorderStrong, width: 1),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      song.title,
                      style: AppTypography.heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: GlassCard.card(radius: 12),
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedRemoveCircle,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Remove from tag',
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context
                          .read<TagProvider>()
                          .removeSongFromTag(song.id);
                      _loadSongs();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    final nameController = TextEditingController(text: tag.name);
    int selectedColor = tag.color;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AlertDialog(
              backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.94),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.glassBorderStrong, width: 1),
              ),
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
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final trimmed = nameController.text.trim();
                    if (trimmed.isNotEmpty) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context
                          .read<TagProvider>()
                          .updateTag(tag.id, trimmed, selectedColor);
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(
                    'Save',
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(color).withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      size: 18,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Add Songs Sheet ──────────────────────────────────────────────────────────

class _AddSongsToTagSheet extends StatefulWidget {
  final Tag tag;
  final VoidCallback onChanged;

  const _AddSongsToTagSheet({required this.tag, required this.onChanged});

  @override
  State<_AddSongsToTagSheet> createState() => _AddSongsToTagSheetState();
}

class _AddSongsToTagSheetState extends State<_AddSongsToTagSheet> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _assignedSongIds = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignedSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedSongs() async {
    final songs = await context.read<TagProvider>().getSongsForTag(widget.tag.id);
    if (mounted) {
      setState(() {
        _assignedSongIds = songs.map((s) => s.id).toSet();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSong(Song song) async {
    final tagProvider = context.read<TagProvider>();
    final isAssigned = _assignedSongIds.contains(song.id);

    setState(() {
      if (isAssigned) {
        _assignedSongIds.remove(song.id);
      } else {
        _assignedSongIds.add(song.id);
      }
    });

    if (isAssigned) {
      await tagProvider.removeSongFromTag(song.id);
    } else {
      await tagProvider.assignSongToTag(song.id, widget.tag.id);
    }

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = context.watch<SongProvider>().songs;
    final tagColor = Color(widget.tag.color);

    final filteredSongs = _searchQuery.isEmpty
        ? allSongs
        : allSongs.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q);
          }).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tagColor.withValues(alpha: 0.35),
                            tagColor.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tagColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedTag01,
                          color: tagColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Songs to Tag', style: AppTypography.heading),
                          const SizedBox(height: 2),
                          Text(
                            widget.tag.name,
                            style: AppTypography.caption.copyWith(
                              color: tagColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        '${_assignedSongIds.length} added',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  height: 44,
                  decoration: GlassCard.card(radius: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 18,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: false,
                          style: AppTypography.body.copyWith(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Filter songs...',
                            hintStyle: AppTypography.caption.copyWith(fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.glassBorder),
              // Song list
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (filteredSongs.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No songs in your library'
                          : 'No matching songs found',
                      style: AppTypography.caption,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      final isAssigned = _assignedSongIds.contains(song.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: GestureDetector(
                          onTap: () => _toggleSong(song),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: isAssigned
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        tagColor.withValues(alpha: 0.28),
                                        tagColor.withValues(alpha: 0.14),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: tagColor.withValues(alpha: 0.6),
                                      width: 1.2,
                                    ),
                                  )
                                : GlassCard.card(radius: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isAssigned
                                        ? tagColor.withValues(alpha: 0.35)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: HugeIcon(
                                      icon: isAssigned
                                          ? HugeIcons.strokeRoundedCheckmarkCircle01
                                          : HugeIcons.strokeRoundedMusicNote01,
                                      size: 18,
                                      color: isAssigned
                                          ? tagColor
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: isAssigned
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isAssigned
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        song.artist.isEmpty
                                            ? 'Unknown Artist'
                                            : song.artist,
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 11,
                                          color: isAssigned
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAssigned
                                        ? tagColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isAssigned
                                          ? tagColor
                                          : AppColors.textDisabled,
                                      width: 1.5,
                                    ),
                                    boxShadow: isAssigned
                                        ? [
                                            BoxShadow(
                                              color: tagColor.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isAssigned
                                      ? const Center(
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedTick01,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
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
  }
}

// ── Glass Action Button ───────────────────────────────────────────────────────

class _GlassTagActionButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final bool isPrimary;
  final Color accentColor;
  final VoidCallback? onPressed;

  const _GlassTagActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.accentColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: isPrimary
            ? GlassCard.accent(radius: 16, accentColor: accentColor)
            : GlassCard.card(radius: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              size: 18,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isPrimary ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
