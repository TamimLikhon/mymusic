import '../database/app_database.dart';

enum QueueSource { allSongs, tag }

enum RepeatMode { none, one, all }

class QueueState {
  final QueueSource source;
  final String? tagId;
  final List<Song> queue;
  final List<Song>? unshuffledQueue;
  final int currentIndex;
  final bool isShuffled;
  final RepeatMode repeatMode;

  QueueState({
    this.source = QueueSource.allSongs,
    this.tagId,
    this.queue = const [],
    this.unshuffledQueue,
    this.currentIndex = 0,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.none,
  });

  QueueState copyWith({
    QueueSource? source,
    String? tagId,
    List<Song>? queue,
    List<Song>? unshuffledQueue,
    int? currentIndex,
    bool? isShuffled,
    RepeatMode? repeatMode,
  }) {
    return QueueState(
      source: source ?? this.source,
      tagId: tagId ?? this.tagId,
      queue: queue ?? this.queue,
      unshuffledQueue: unshuffledQueue ?? this.unshuffledQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  Song? get currentSong =>
      queue.isNotEmpty && currentIndex < queue.length
          ? queue[currentIndex]
          : null;
}
