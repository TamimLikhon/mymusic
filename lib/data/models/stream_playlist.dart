import 'dart:convert';
import 'stream_song.dart';

class StreamPlaylist {
  final String id;
  String name;
  String? thumbnailUrl;
  List<StreamSong> songs;

  StreamPlaylist({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    List<StreamSong>? songs,
  }) : songs = songs ?? [];

  bool containsSong(String videoId) =>
      songs.any((s) => s.videoId == videoId);

  /// Returns true if the song was added (false if already present).
  bool addSong(StreamSong song) {
    if (containsSong(song.videoId)) return false;
    songs.add(song);
    thumbnailUrl ??= song.thumbUrl;
    return true;
  }

  bool removeSong(String videoId) {
    final before = songs.length;
    songs.removeWhere((s) => s.videoId == videoId);
    // Re-compute thumbnail if first song was removed
    if (songs.isNotEmpty && thumbnailUrl != null) {
      thumbnailUrl = songs.first.thumbUrl;
    } else if (songs.isEmpty) {
      thumbnailUrl = null;
    }
    return songs.length < before;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumbnailUrl': thumbnailUrl,
        'songs': songs.map((s) => s.toJson()).toList(),
      };

  factory StreamPlaylist.fromJson(Map<String, dynamic> json) =>
      StreamPlaylist(
        id: json['id'] as String,
        name: json['name'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        songs: (json['songs'] as List<dynamic>)
            .map((e) => StreamSong.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encodeList(List<StreamPlaylist> playlists) =>
      jsonEncode(playlists.map((p) => p.toJson()).toList());

  static List<StreamPlaylist> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => StreamPlaylist.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
