import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stream_provider.dart';
import '../../providers/playlist_provider.dart';
import 'create_playlist_page.dart';
import 'playlist_detail_sheet.dart';
import '../../widgets/add_to_playlist_sheet.dart';
import '../../widgets/animated_bars.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocus.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(q);
    _recentSearches.insert(0, q);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<MusicStreamProvider>().search(query);
      }
    });
  }

  void _submitSearch(String query) {
    if (query.trim().isNotEmpty) {
      _saveRecentSearch(query);
      _searchController.text = query;
      _searchFocus.unfocus();
      context.read<MusicStreamProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<MusicStreamProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1A1A2E), AppColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedRadio,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Stream',
                        style: AppTypography.heading.copyWith(fontSize: 26),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePlaylistPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.textPrimary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    onSubmitted: _submitSearch,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search YouTube Music…',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C63FF),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            // ── Loading Bar ────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: streamProvider.isSearching ? 2 : 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: const Color(0xFF6C63FF),
                minHeight: 2,
              ),
            ),

            // ── Recent Searches (when focused and empty) ────────────────────
            if (_searchFocus.hasFocus &&
                _searchController.text.trim().isEmpty &&
                _recentSearches.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Searches',
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches
                          .map(
                            (query) => ActionChip(
                              label: Text(query, style: AppTypography.caption),
                              backgroundColor: AppColors.surface,
                              side: BorderSide(color: AppColors.surfaceBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onPressed: () => _submitSearch(query),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            // ── Results / Home ─────────────────────────────────────────────
            Expanded(
              child: streamProvider.error != null
                  ? _ErrorView(
                      error: streamProvider.error!,
                      onRetry: () =>
                          streamProvider.search(_searchController.text),
                    )
                  : _searchController.text.trim().isEmpty &&
                        streamProvider.results.isEmpty &&
                        !streamProvider.isSearching
                  ? const _StreamHomeView()
                  : streamProvider.results.isEmpty &&
                        !streamProvider.isSearching
                  ? const _EmptyView()
                  : _ResultsList(
                      streamProvider: streamProvider,
                      onSaveSearch: _saveRecentSearch,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results List ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  final void Function(String query) onSaveSearch;
  const _ResultsList({
    required this.streamProvider,
    required this.onSaveSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      itemCount: streamProvider.results.length,
      itemBuilder: (context, index) {
        final song = streamProvider.results[index];
        final isCurrentSong =
            streamProvider.currentSong?.videoId == song.videoId;

        return _AnimatedSongTile(
          index: index,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onSaveSearch(song.title);
                streamProvider.playSong(song, index);
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.surfaceHigh,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppColors.textPrimary,
                        ),
                        title: Text(
                          'Play Now',
                          style: AppTypography.bodyMedium,
                        ),
                        onTap: () {
                          streamProvider.playSong(song, index);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.playlist_play_rounded,
                          color: AppColors.textPrimary,
                        ),
                        title: Text(
                          'Play Next',
                          style: AppTypography.bodyMedium,
                        ),
                        onTap: () {
                          streamProvider.addToQueue(song);
                          streamProvider.reorderQueue(
                            streamProvider.queue.length - 1,
                            streamProvider.queueIndex + 1,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.textPrimary,
                        ),
                        title: Text(
                          'Add to Queue',
                          style: AppTypography.bodyMedium,
                        ),
                        onTap: () {
                          streamProvider.addToQueue(song);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.playlist_add_rounded,
                          color: AppColors.textPrimary,
                        ),
                        title: Text(
                          'Add to Playlist',
                          style: AppTypography.bodyMedium,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddToPlaylistSheet(song: song),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
              splashColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              highlightColor: const Color(0xFF6C63FF).withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrentSong
                      ? const Color(0xFF6C63FF).withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: isCurrentSong
                      ? Border(
                          left: BorderSide(
                            color: const Color(0xFF6C63FF),
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: song.thumbUrl != null
                                ? Image.network(
                                    song.thumbUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _Placeholder(size: 52),
                                  )
                                : _Placeholder(size: 52),
                          ),
                          // Playing indicator overlay
                          if (isCurrentSong)
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: streamProvider.isBuffering
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : AnimatedBars(
                                        isPlaying: streamProvider.isPlaying,
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Title & Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCurrentSong
                                    ? const Color(0xFF9D97FF)
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              song.artists,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Add to Playlist button
                      IconButton(
                        icon: const Icon(
                          Icons.playlist_add_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddToPlaylistSheet(song: song),
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),

                      // Duration badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          song.duration,
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Animated tile — slides + fades in as results stream in ───────────────────

class _AnimatedSongTile extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedSongTile({required this.index, required this.child});

  @override
  State<_AnimatedSongTile> createState() => _AnimatedSongTileState();
}

class _AnimatedSongTileState extends State<_AnimatedSongTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger by index (cap at 400ms so late items don't wait too long)
    final delay = Duration(milliseconds: (widget.index * 40).clamp(0, 400));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Empty / Error views ───────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedMusicNote01,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            'Search for songs, artists or albums',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text('Powered by YouTube Music', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.redAccent.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;
  const _Placeholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Icon(
        Icons.music_note,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        size: size * 0.4,
      ),
    );
  }
}

// ── Stream Home View ──────────────────────────────────────────────────────────

class _StreamHomeView extends StatelessWidget {
  const _StreamHomeView();

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final history = playlistProvider.history;
    final playlists = playlistProvider.playlists;

    if (history.isEmpty && playlists.isEmpty) {
      return const _EmptyView();
    }

    return CustomScrollView(
      slivers: [
        if (history.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Recently Played',
                style: AppTypography.heading.copyWith(fontSize: 18),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final song = history[index];
                  return GestureDetector(
                    onTap: () =>
                        context.read<MusicStreamProvider>().playSong(song, -1),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: song.thumbUrl != null
                                ? Image.network(
                                    song.thumbUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _Placeholder(size: 100),
                                  )
                                : _Placeholder(size: 100),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        if (playlists.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Text(
                'Your Playlists',
                style: AppTypography.heading.copyWith(fontSize: 18),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final playlist = playlists[index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PlaylistDetailSheet(playlist: playlist),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: playlist.thumbnailUrl != null
                                ? Image.network(
                                    playlist.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: AppColors.seedGradient(
                                            playlist.name,
                                          ),
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedMusicNote01,
                                          color: Colors.white70,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: AppColors.seedGradient(
                                          playlist.name,
                                        ),
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: HugeIcon(
                                        icon:
                                            HugeIcons.strokeRoundedMusicNote01,
                                        color: Colors.white70,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${playlist.songs.length} song${playlist.songs.length == 1 ? '' : 's'}',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: playlists.length),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
