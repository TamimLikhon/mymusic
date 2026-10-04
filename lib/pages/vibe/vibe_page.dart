import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../data/database/app_database.dart';
import '../../providers/song_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/permission_service.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/assign_tag_sheet.dart';

class VibePage extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const VibePage({super.key, this.onSettingsTap});

  @override
  State<VibePage> createState() => _VibePageState();
}

class _VibePageState extends State<VibePage> {
  bool _isScanning = false;

  // ── Inline search state ──────────────────────────────────────────────────
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Song> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final songs = context.read<SongProvider>().songs;
    final q = query.toLowerCase();
    setState(() {
      _searchResults = query.isEmpty
          ? []
          : songs.where((s) {
              return s.title.toLowerCase().contains(q) ||
                  s.artist.toLowerCase().contains(q) ||
                  s.album.toLowerCase().contains(q);
            }).toList();
    });
  }

  void _openSearch() {
    setState(() => _searchActive = true);
    Future.delayed(const Duration(milliseconds: 50), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchResults = [];
    });
  }

  Future<void> _scanSongs() async {
    final permissionService = PermissionService();
    final provider = context.read<SongProvider>();
    final granted = await permissionService.requestStoragePermission(allowOpenSettings: true);

    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission required to scan songs'),
        ),
      );
      return;
    }

    setState(() => _isScanning = true);

    try {
      await provider.scanAndImport();
      if (mounted) {
        final count = provider.scannedCount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count > 0 ? 'Found $count new songs 🎵' : 'No new songs found',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    setState(() => _isScanning = false);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Midnight violet background gradient ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0B28),
                  Color(0xFF08081A),
                  Color(0xFF0A0820),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // ── Ambient glow orbs ────────────────────────────────────────────
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 140,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    blurRadius: 110,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    blurRadius: 90,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // ── Main content ─────────────────────────────────────────────────
          Consumer3<SongProvider, TagProvider, AudioProvider>(
            builder: (context, songProvider, tagProvider, audioProvider, _) {
              if (songProvider.isLoading && songProvider.songs.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                );
              }

              if (songProvider.songs.isEmpty) {
                return _buildEmptyState();
              }

              final content =
                  _buildContent(songProvider, tagProvider, audioProvider);

              // Overlay search results panel when search is active
              if (_searchActive) {
                return Stack(
                  children: [
                    content,
                    _buildSearchOverlay(audioProvider, songProvider),
                  ],
                );
              }

              return content;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glass icon container
                GlassContainer(
                  radius: 32,
                  blurSigma: 20,
                  padding: const EdgeInsets.all(28),
                  tint: AppColors.primary,
                  tintOpacity: 0.12,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedFolderMusic,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Your library is empty',
                  style: AppTypography.hero.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Scan your device to find audio files and start listening.',
                  style: AppTypography.caption.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: _scanSongs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: GlassCard.accent(
                      radius: 30,
                      accentColor: AppColors.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Scan Device',
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
        Positioned(
          top: 0,
          right: 20,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: widget.onSettingsTap,
                child: GlassContainer(
                  radius: 14,
                  blurSigma: 20,
                  padding: const EdgeInsets.all(10),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings01,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Full-page search overlay that slides over the content
  Widget _buildSearchOverlay(
      AudioProvider audioProvider, SongProvider songProvider) {
    return GestureDetector(
      onTap: () {}, // absorb taps so the list doesn't dismiss
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.95),
                  AppColors.surface.withValues(alpha: 0.98),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Search bar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: GlassContainer(
                      radius: 18,
                      blurSigma: 20,
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              style: AppTypography.body,
                              cursorColor: AppColors.primary,
                              decoration: InputDecoration(
                                hintText: 'Songs, artists, albums...',
                                hintStyle: AppTypography.caption,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                          IconButton(
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft02,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: _closeSearch,
                            tooltip: 'Close search',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Results
                  Expanded(
                    child: _searchController.text.isEmpty
                        ? _buildSearchIdle()
                        : _searchResults.isEmpty
                            ? _buildSearchNoResults()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final song = _searchResults[index];
                                  return SongTile(
                                    song: song,
                                    isPlaying:
                                        audioProvider.currentSong?.id ==
                                        song.id,
                                    onTap: () {
                                      audioProvider.playAllSongs(
                                        _searchResults,
                                        startIndex: index,
                                      );
                                    },
                                    onLongPress: () => _showSongOptions(song),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            radius: 22,
            blurSigma: 20,
            tint: AppColors.primary,
            tintOpacity: 0.10,
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Find your music', style: AppTypography.heading),
          const SizedBox(height: 6),
          Text('Search by song, artist or album',
              style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildSearchNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No results for', style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(
            '"${_searchController.text}"',
            style: AppTypography.heading.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    SongProvider songProvider,
    TagProvider tagProvider,
    AudioProvider audioProvider,
  ) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: Colors.transparent,
          pinned: false,
          floating: true,
          snap: true,
          expandedHeight: 80,
          toolbarHeight: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.accent,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'MyMusic',
                                    style: AppTypography.display.copyWith(
                                      fontSize: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons — glass pill style
                          _AppBarAction(
                            onTap: _isScanning ? null : _scanSongs,
                            child: _isScanning
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const HugeIcon(
                                    icon: HugeIcons
                                        .strokeRoundedArrowReloadHorizontal,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          _AppBarAction(
                            onTap: () {
                              final songs = context.read<SongProvider>().songs;
                              if (songs.isNotEmpty) {
                                context
                                    .read<AudioProvider>()
                                    .shuffleAllSongs(songs);
                              }
                            },
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedShuffle,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _AppBarAction(
                            onTap: _openSearch,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _AppBarAction(
                            onTap: widget.onSettingsTap,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSettings01,
                              size: 15,
                              color: Colors.white,
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
        ),

        // ── Recently Played ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: FutureBuilder<List<Song>>(
            future: songProvider.getRecentlyPlayed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final recentSongs = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'RECENTLY PLAYED',
                      style: AppTypography.overline,
                    ),
                  ),
                  SizedBox(
                    height: 118,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recentSongs.length,
                      itemBuilder: (context, index) {
                        final song = recentSongs[index];
                        final isActive =
                            audioProvider.currentSong?.id == song.id;
                        final colors = AppColors.seedGradient(song.title);
                        return GestureDetector(
                          onTap: () {
                            audioProvider.playAllSongs(
                              songProvider.songs,
                              startIndex: songProvider.songs.indexWhere(
                                (s) => s.id == song.id,
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  decoration: isActive
                                      ? BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: SongArtWidget(
                                    song: song,
                                    colors: colors,
                                    isPlaying: isActive,
                                    size: 80,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  song.title,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),

        // ── Tags ──────────────────────────────────────────────────────────────
        if (tagProvider.tags.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Text('YOUR TAGS', style: AppTypography.overline),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tagProvider.tags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = tagProvider.tags[index];
                  final count = tagProvider.songCounts[tag.id] ?? 0;
                  return TagChip(
                    name: tag.name,
                    color: tag.color,
                    songCount: count,
                    onTap: () => Navigator.pushNamed(context, '/tag/${tag.id}'),
                  );
                },
              ),
            ),
          ),
        ],

        // ── All Songs ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ALL SONGS', style: AppTypography.overline),
                Text(
                  '${songProvider.songs.length} tracks',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = songProvider.songs[index];
            return SongTile(
              song: song,
              index: index,
              isPlaying: audioProvider.currentSong?.id == song.id,
              onTap: () {
                audioProvider.playAllSongs(
                  songProvider.songs,
                  startIndex: index,
                );
              },
              onLongPress: () => _showSongOptions(song),
            );
          }, childCount: songProvider.songs.length),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surfaceHigh.withValues(alpha: 0.85),
                    AppColors.surface.withValues(alpha: 0.90),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorder, width: 0.8),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 14, bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
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
                    _SheetOption(
                      icon: HugeIcons.strokeRoundedNext,
                      color: AppColors.primary,
                      title: 'Play Next',
                      subtitle: 'Add to front of queue',
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AudioProvider>().playNext(song);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${song.title}" plays next'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _SheetOption(
                      icon: HugeIcons.strokeRoundedEdit01,
                      color: AppColors.primary,
                      title: 'Edit Name',
                      onTap: () {
                        Navigator.pop(context);
                        _showRenameDialog(song);
                      },
                    ),
                    _SheetOption(
                      icon: HugeIcons.strokeRoundedTag01,
                      color: AppColors.accent,
                      title: 'Assign to tag',
                      onTap: () {
                        Navigator.pop(context);
                        AssignTagSheet.show(context, song.id, song.title);
                      },
                    ),
                    _SheetOption(
                      icon: HugeIcons.strokeRoundedDelete01,
                      color: AppColors.secondary,
                      title: 'Remove from library',
                      titleColor: AppColors.secondary,
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDelete(song.id, song.title);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(Song song) {
    final controller = TextEditingController(text: song.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Edit Song Name', style: AppTypography.heading),
        content: TextField(
          controller: controller,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'New song name',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != song.title) {
                FocusManager.instance.primaryFocus?.unfocus();
                final nav = Navigator.of(context);
                final scaffoldMsg = ScaffoldMessenger.of(context);
                final success = await context.read<SongProvider>().renameSong(
                  song,
                  newTitle,
                );

                nav.pop();
                if (success) {
                  scaffoldMsg.showSnackBar(
                    const SnackBar(content: Text('Song renamed successfully')),
                  );
                } else {
                  scaffoldMsg.showSnackBar(
                    const SnackBar(content: Text('Failed to rename song')),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Song', style: AppTypography.heading),
        content: Text(
          'Remove "$songTitle" from your library?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<SongProvider>().deleteSong(songId);
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: AppTypography.body.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Bar Action Button ─────────────────────────────────────────────────────

class _AppBarAction extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _AppBarAction({this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        radius: 12,
        blurSigma: 16,
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }
}

// ── Glass Bottom Sheet Option ─────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final dynamic icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SheetOption({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: HugeIcon(icon: icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.caption)
          : null,
      onTap: onTap,
    );
  }
}
