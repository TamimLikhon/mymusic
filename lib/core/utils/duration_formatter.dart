String formatDuration(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes;
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String formatDurationFromSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
