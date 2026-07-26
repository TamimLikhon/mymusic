import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
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
  List<Song> _searchResults = [];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () =>
                context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer(),
          ),
        ),
        title: Text('Search', style: AppTypography.heading),
      ),
      body: Column(
        children: [
          // Neumorphic search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: Neumorphic.pressed(radius: 14),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: AppTypography.body,
                      cursorColor: AppColors.primary,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists...',
                        hintStyle: AppTypography.caption,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded,
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
          Expanded(
            child: _searchController.text.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: Neumorphic.raisedCircle(),
                          child: const Icon(
                            Icons.search_rounded,
                            size: 36,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Search your library',
                            style: AppTypography.caption),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Text('No results found',
                            style: AppTypography.caption),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final song = _searchResults[index];
                          return SongTile(
                            song: song,
                            isPlaying:
                                audioProvider.currentSong?.id == song.id,
                            onTap: () {
                              audioProvider.playAllSongs(_searchResults,
                                  startIndex: index);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
