import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/duration_formatter.dart';
import '../../providers/tag_provider.dart';
import '../../providers/audio_provider.dart';
import '../../data/database/app_database.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/retro_button.dart';

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

    // Tag was deleted while page was open — go back safely
    if (tagOrNull == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tag = tagOrNull;
    final tagColor = Color(tag.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(tag.name, style: AppTypography.heading.copyWith(fontSize: 12)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditTagDialog(context, tag),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
          : Column(
              children: [
                _buildHeader(tag, tagColor),
                if (_songs.isNotEmpty) _buildActionButtons(tagColor, audioProvider),
                Expanded(child: _buildSongList(tagColor, audioProvider)),
              ],
            ),
    );
  }

  Widget _buildHeader(Tag tag, Color tagColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tagColor.withValues(alpha: 0.15),
            AppColors.background,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tagColor.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(Icons.label, color: tagColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.name,
                  style: AppTypography.heading.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.music_note, size: 14, color: tagColor),
                    const SizedBox(width: 4),
                    Text(
                      '${_songs.length} songs',
                      style: AppTypography.caption.copyWith(color: tagColor),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 14, color: tagColor),
                    const SizedBox(width: 4),
                    Text(
                      formatDuration(_totalDuration),
                      style: AppTypography.caption.copyWith(color: tagColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color tagColor, AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: RetroButton(
              label: 'Play All',
              icon: Icons.play_arrow,
              color: tagColor,
              onPressed: () {
                audioProvider.playFromTag(widget.tagId, _songs);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RetroButton(
              label: 'Shuffle',
              icon: Icons.shuffle,
              color: AppColors.cream,
              onPressed: () {
                audioProvider.shuffleFromTag(widget.tagId, _songs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(Color tagColor, AudioProvider audioProvider) {
    if (_songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 48, color: tagColor.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No songs in this tag', style: AppTypography.caption),
            const SizedBox(height: 8),
            Text(
              'Add songs from your library',
              style: AppTypography.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return Dismissible(
          key: Key(song.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.burntOrange,
            child: const Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Remove Song', style: AppTypography.heading.copyWith(fontSize: 12)),
                content: Text(
                  'Remove "${song.title}" from this tag?',
                  style: AppTypography.body,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: AppTypography.caption),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Remove', style: AppTypography.body.copyWith(color: AppColors.burntOrange)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<TagProvider>().removeSongFromTag(song.id);
            setState(() {
              _songs.removeAt(index);
            });
          },
          child: SongTile(
            song: song,
            index: index,
            isPlaying: audioProvider.currentSong?.id == song.id,
            onTap: () {
              audioProvider.playFromTag(widget.tagId, _songs, startIndex: index);
            },
            onLongPress: () => _showSongOptions(context, song),
          ),
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                child: Text(
                  song.title,
                  style: AppTypography.body.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: AppColors.burntOrange),
                title: Text(
                  'Remove from tag',
                  style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.burntOrange),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<TagProvider>().removeSongFromTag(song.id);
                  _loadSongs();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    final nameController = TextEditingController(text: tag.name);
    int selectedColor = tag.color;

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
                    context.read<TagProvider>().updateTag(
                          tag.id,
                          nameController.text,
                          selectedColor,
                        );
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}
