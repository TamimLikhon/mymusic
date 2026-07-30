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

  @override
  void initState() {
    super.initState();
    // Auto-focus when tab is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text('Search', style: AppTypography.display.copyWith(fontSize: 28)),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: GlassCard.card(radius: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.textDisabled, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: AppTypography.body,
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: 'Songs, artists, albums...',
                          hintStyle: AppTypography.caption,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01,
                            color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
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
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final song = _searchResults[index];
                            return SongTile(
                              song: song,
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
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('Find your music', style: AppTypography.heading),
          const SizedBox(height: 8),
          Text(
            'Search by song, artist or album',
            style: AppTypography.caption,
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
}
