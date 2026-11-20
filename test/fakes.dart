import 'package:rushagram_app/core/appambit/analytics.dart';
import 'package:rushagram_app/core/appambit/diagnostics.dart';
import 'package:rushagram_app/core/appambit/push_service.dart';
import 'package:rushagram_app/core/errors.dart';
import 'package:rushagram_app/core/local_store.dart';
import 'package:rushagram_app/features/daily/data/daily_repository.dart';
import 'package:rushagram_app/features/daily/data/puzzle.dart';

final now = DateTime.utc(2026, 11, 20, 19, 0, 0);

class FakeStore implements LocalStore {
  FakeStore({this.nickname});
  @override
  final String playerId = 'player-test-0001';
  @override
  String? nickname;
  @override
  bool pushAsked = false;
  @override
  Future<void> saveNickname(String n) async => nickname = n.trim();
  @override
  Future<void> markPushAsked() async => pushAsked = true;
}

class FakeAnalytics implements Analytics {
  final events = <String>[];
  @override
  void track(String event, [Map<String, String> properties = const {}]) => events.add(event);
}

class FakePush implements PushService {
  int asked = 0;
  @override
  Future<void> start() async {}
  @override
  Future<bool> requestPermission() async {
    asked++;
    return true;
  }

  @override
  void onOpened(void Function(Map<String, String> data) handler) {}
}

class FakeDiagnostics implements Diagnostics {
  int crashes = 0;
  @override
  void testCrash() => crashes++;
}

Result result({int timeMs = 23000, int rank = 14, int total = 230}) => Result(
      timeMs: timeMs,
      rank: rank,
      total: total,
      top: [
        const RankRow(position: 1, nickname: 'Mia', timeMs: 11000, me: false),
        const RankRow(position: 2, nickname: 'Leo', timeMs: 15000, me: false),
      ],
    );

/// The word is "PUZZLE"-free on purpose: letters "TOMATO" scrambled, answer "TOMATO" is checked by the fake cloud.
class FakeRepo implements DailyRepository {
  FakeRepo({this.answer = 'TOMATO', this.letters = 'MOTATO', this.started = false, this.solved});

  final String answer;
  final String letters;
  bool started;
  Result? solved;
  AppFailure? failNext;
  final guesses = <String>[];

  Puzzle get puzzle => Puzzle(day: '2026-11-20', number: 12, letters: letters, nextAt: DateTime.utc(2026, 11, 21));

  void _maybeFail() {
    final f = failNext;
    failNext = null;
    if (f != null) throw f;
  }

  @override
  Future<Today> today() async {
    _maybeFail();
    return Today(puzzle: puzzle, serverNow: now, startedAt: started ? now.subtract(const Duration(seconds: 5)) : null, result: solved);
  }

  @override
  Future<RunStart> startRun() async {
    _maybeFail();
    started = true;
    return RunStart(startedAt: now, serverNow: now);
  }

  @override
  Future<GuessOutcome> submitGuess(String guess) async {
    _maybeFail();
    guesses.add(guess);
    if (guess.toUpperCase() != answer) return const Wrong();
    return Solved(solved = result());
  }

  @override
  Future<Result> ranking() async => solved!;
}
