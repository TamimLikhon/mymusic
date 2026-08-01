import 'package:yt_flutter_musicapi/models/searchModel.dart';

class StreamSong {
  final String title;
  final String artists;
  final String duration;
  final String videoId;
  final String? thumbUrl;
  final String? audioUrl;

  StreamSong({
    required this.title,
    required this.artists,
    required this.duration,
    required this.videoId,
    this.thumbUrl,
    this.audioUrl,
  });

  factory StreamSong.fromSearchResult(SearchResult result) {
    return StreamSong(
      title: result.title,
      artists: result.artists,
      duration: result.duration ?? '0:00',
      videoId: result.videoId,
      thumbUrl: result.albumArt,
      audioUrl: result.audioUrl,
    );
  }

  factory StreamSong.fromMap(Map<dynamic, dynamic> map) {
    return StreamSong(
      title: map['title'] ?? 'Unknown Title',
      artists: map['artists'] ?? 'Unknown Artist',
      duration: map['duration'] ?? '0:00',
      videoId: map['videoId'] ?? '',
      thumbUrl: map['thumbUrl'],
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'artists': artists,
        'duration': duration,
        'videoId': videoId,
        'thumbUrl': thumbUrl,
        'audioUrl': audioUrl,
      };

  factory StreamSong.fromJson(Map<String, dynamic> json) {
    return StreamSong(
      title: json['title'] ?? 'Unknown Title',
      artists: json['artists'] ?? 'Unknown Artist',
      duration: json['duration'] ?? '0:00',
      videoId: json['videoId'] ?? '',
      thumbUrl: json['thumbUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  StreamSong copyWith({
    String? title,
    String? artists,
    String? duration,
    String? videoId,
    String? thumbUrl,
    String? audioUrl,
  }) {
    return StreamSong(
      title: title ?? this.title,
      artists: artists ?? this.artists,
      duration: duration ?? this.duration,
      videoId: videoId ?? this.videoId,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
