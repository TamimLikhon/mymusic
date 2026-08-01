import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stream_provider.dart';
import '../../widgets/stream_mini_player.dart';
import '../../widgets/animated_bars.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
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
                  colors: [
                    const Color(0xFF1A1A2E),
                    AppColors.background,
                  ],
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
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

            // ── Results ────────────────────────────────────────────────────
            Expanded(
              child: streamProvider.error != null
                  ? _ErrorView(
                      error: streamProvider.error!,
                      onRetry: () =>
                          streamProvider.search(_searchController.text),
                    )
                  : streamProvider.results.isEmpty && !streamProvider.isSearching
                  ? const _EmptyView()
                  : _ResultsList(streamProvider: streamProvider),
            ),

            // ── Mini Player ────────────────────────────────────────────────
            const StreamMiniPlayer(),
          ],
        ),
      ),
    );
  }
}

// ── Results List ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  const _ResultsList({required this.streamProvider});

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
              onTap: () => streamProvider.playSong(song, index),
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
                                    errorBuilder: (_, __, ___) =>
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
                      const SizedBox(width: 8),

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
          Text(
            'Powered by YouTube Music',
            style: AppTypography.caption,
          ),
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
