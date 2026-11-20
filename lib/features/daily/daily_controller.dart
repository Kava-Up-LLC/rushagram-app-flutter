import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/appambit/analytics.dart';
import '../../core/appambit/push_service.dart';
import '../../core/errors.dart';
import '../../core/format.dart';
import '../../core/local_store.dart';
import 'board.dart';
import 'data/daily_repository.dart';
import 'data/puzzle.dart';

enum DailyPhase { loading, failed, ready, running, solved }

/// Today's game: load → Start → tap tiles → solved. The time and the rank come from the cloud;
/// the phone's clock is only used to draw the timer.
class DailyController extends ChangeNotifier {
  DailyController({
    required this.repository,
    required this.analytics,
    required this.push,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DailyRepository repository;
  final Analytics analytics;
  final PushService push;
  final LocalStore store;
  final DateTime Function() _clock;

  DailyPhase phase = DailyPhase.loading;
  Puzzle? puzzle;
  Board? board;
  Result? result;
  DateTime? startedAt;

  /// Last failure (shown as the "No connection" banner). Cleared by the next successful call.
  AppFailure? failure;
  bool busy = false;

  /// Bumped on every wrong word, so the view can shake the tiles.
  int wrongCount = 0;
  bool showWrongLine = false;

  /// True right after solving in this session (the slots flip to amber, then the ranking).
  bool justSolved = false;

  /// Solved in this session (vs. opening the app again the same day).
  bool justSolvedThisSession = false;

  /// Ask once for notifications, on the result after the first solve.
  bool askPush = false;

  Duration _offset = Duration.zero; // database clock − phone clock
  Timer? _wrongTimer;
  bool _disposed = false;

  DateTime get now => _clock().toUtc().add(_offset);
  Duration get elapsed => startedAt == null ? Duration.zero : now.difference(startedAt!);
  Duration get nextIn => puzzle == null ? Duration.zero : puzzle!.nextAt.difference(now);

  void _syncClock(DateTime serverNow) => _offset = serverNow.difference(_clock().toUtc());

  Future<void> load() async {
    if (phase != DailyPhase.solved && phase != DailyPhase.running) phase = DailyPhase.loading;
    failure = null;
    _notify();
    try {
      final t = await repository.today();
      _syncClock(t.serverNow);
      final newDay = puzzle?.day != t.puzzle.day;
      puzzle = t.puzzle;
      startedAt = t.startedAt;
      result = t.result;
      if (result != null) {
        phase = DailyPhase.solved;
      } else if (startedAt != null) {
        if (newDay || board == null || phase != DailyPhase.running) board = Board(t.puzzle.letters);
        phase = DailyPhase.running;
      } else {
        board = Board(t.puzzle.letters);
        phase = DailyPhase.ready;
      }
      if (newDay) analytics.track('puzzle_opened', {'number': '${t.puzzle.number}'});
    } on AppFailure catch (e) {
      failure = e;
      if (puzzle == null) phase = DailyPhase.failed;
    }
    _notify();
  }

  Future<void> start() async {
    if (busy || phase != DailyPhase.ready) return;
    busy = true;
    failure = null;
    _notify();
    try {
      final r = await repository.startRun();
      _syncClock(r.serverNow);
      startedAt = r.startedAt;
      phase = DailyPhase.running;
      analytics.track('run_started');
    } on AppFailure catch (e) {
      failure = e;
    }
    busy = false;
    _notify();
  }

  void tapTile(int letter) {
    if (phase != DailyPhase.running || busy || board == null) return;
    board = board!.tap(letter);
    showWrongLine = false;
    _notify();
    if (board!.isFull) submit();
  }

  void untapSlot(int slot) {
    if (phase != DailyPhase.running || busy || board == null) return;
    board = board!.untap(slot);
    _notify();
  }

  void shuffle() {
    if (phase != DailyPhase.running || busy || board == null) return;
    board = board!.shuffle();
    _notify();
  }

  void clear() {
    if (phase != DailyPhase.running || busy || board == null) return;
    board = board!.clear();
    _notify();
  }

  /// Sends the full guess. A network failure doesn't count: the tiles stay as they were.
  Future<void> submit() async {
    final b = board;
    if (b == null || !b.isFull || busy) return;
    busy = true;
    failure = null;
    _notify();
    try {
      final outcome = await repository.submitGuess(b.guess);
      switch (outcome) {
        case Solved(:final result):
          this.result = result;
          phase = DailyPhase.solved;
          justSolved = true;
          justSolvedThisSession = true;
          askPush = !store.pushAsked;
          analytics.track('puzzle_solved', {'time_ms': '${result.timeMs}', 'rank': '${result.rank}'});
        case Wrong():
          wrongCount++;
          board = b.clear();
          showWrongLine = true;
          analytics.track('guess_wrong');
          _wrongTimer?.cancel();
          _wrongTimer = Timer(const Duration(seconds: 2), () {
            showWrongLine = false;
            _notify();
          });
      }
    } on AppFailure catch (e) {
      failure = e;
    }
    busy = false;
    _notify();
  }

  /// The share text, e.g. "Rushagram #12 · 0:23 · #14 today".
  String? shareText() {
    final p = puzzle, r = result;
    if (p == null || r == null) return null;
    analytics.track('result_shared');
    return formatShare(number: p.number, timeMs: r.timeMs, rank: r.rank);
  }

  Future<void> answerPush({required bool turnOn}) async {
    askPush = false;
    _notify();
    await store.markPushAsked();
    if (turnOn) await push.requestPermission();
  }

  void doneCelebrating() {
    justSolved = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _wrongTimer?.cancel();
    super.dispose();
  }
}
