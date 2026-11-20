/// 23000 ms → "0:23", 83400 → "1:23". Times are whole seconds on screen.
String formatTime(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Time left until the next puzzle: "5h 12m", "12m", "less than a minute".
String formatCountdown(Duration left) {
  if (left.inMinutes < 1) return 'less than a minute';
  final h = left.inHours;
  final m = left.inMinutes % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

/// The share text: "Rushagram #12 · 0:23 · #14 today".
String formatShare({required int number, required int timeMs, required int rank}) =>
    'Rushagram #$number · ${formatTime(timeMs)} · #$rank today';

final _nickname = RegExp(r'^[A-Za-z0-9 ]{2,16}$');
bool isValidNickname(String v) => _nickname.hasMatch(v.trim());
