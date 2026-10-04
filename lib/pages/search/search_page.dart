import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/song_provider.dart';
import '../../providers/audio_provider.dart';
import '../../data/database/app_database.dart';
import '../../widgets/song_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Song> _searchResults = [];
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final songs = context.read<SongProvider>().songs;
    final lowercaseQuery = query.toLowerCase();

    setState(() {
      _searchResults = songs.where((song) {
        return song.title.toLowerCase().contains(lowercaseQuery) ||
            song.artist.toLowerCase().contains(lowercaseQuery) ||
            song.album.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Cosmos Ambient Glow Orbs ───────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Search',
                          style: AppTypography.display.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Frosted Glass Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _isFocused
                          ? AppColors.glassFillStrong
                          : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _isFocused
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.glassBorder,
                        width: 1.2,
                      ),
                      boxShadow: _isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: _isFocused
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: _onSearchChanged,
                            style: AppTypography.body.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'Songs, artists, albums...',
                              hintStyle: AppTypography.caption.copyWith(
                                fontSize: 14,
                                color: AppColors.textDisabled,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedCancel01,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Results
                Expanded(
                  child: _searchController.text.isEmpty
                      ? _buildIdleState()
                      : _searchResults.isEmpty
                          ? _buildNoResults()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final song = _searchResults[index];
                                return SongTile(
                                  song: song,
                                  index: index,
                                  isPlaying: audioProvider.currentSong?.id == song.id,
                                  onTap: () {
                                    audioProvider.playAllSongs(
                                      _searchResults,
                                      startIndex: index,
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Find your music',
            style: AppTypography.heading.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Search instantly across tracks, artists & albums',
            style: AppTypography.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
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
                icon: HugeIcons.strokeRoundedSearchRemove,
                size: 30,
                color: AppColors.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('No results found for', style: AppTypography.caption),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '"${_searchController.text}"',
              style: AppTypography.heading.copyWith(
                color: AppColors.primaryLight,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
