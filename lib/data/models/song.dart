class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String filePath;
  final int fileSize;
  final int addedAt;
  final int? lastPlayed;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    required this.fileSize,
    required this.addedAt,
    this.lastPlayed,
  });
}
