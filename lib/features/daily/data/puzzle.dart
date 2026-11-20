/// Today's puzzle as the phone sees it: never the word, only the letters.
class Puzzle {
  const Puzzle({required this.day, required this.number, required this.letters, required this.nextAt});

  final String day;
  final int number;
  final String letters;
  final DateTime nextAt;
}

class RankRow {
  const RankRow({required this.position, required this.nickname, required this.timeMs, required this.me});

  factory RankRow.fromJson(Map<String, dynamic> j) => RankRow(
        position: (j['position'] as num).toInt(),
        nickname: j['nickname'] as String,
        timeMs: (j['time_ms'] as num).toInt(),
        me: j['me'] == true,
      );

  final int position;
  final String nickname;
  final int timeMs;
  final bool me;
}

/// Your solved run: time, rank among today's solvers, and the top 20.
class Result {
  const Result({required this.timeMs, required this.rank, required this.total, required this.top});

  factory Result.fromJson(Map<String, dynamic> j) => Result(
        timeMs: (j['time_ms'] as num).toInt(),
        rank: (j['rank'] as num).toInt(),
        total: (j['total'] as num).toInt(),
        top: [for (final r in (j['top'] as List? ?? const [])) RankRow.fromJson(Map<String, dynamic>.from(r as Map))],
      );

  final int timeMs;
  final int rank;
  final int total;
  final List<RankRow> top;
}

/// What `today` returns.
class Today {
  const Today({required this.puzzle, required this.serverNow, this.startedAt, this.result});

  final Puzzle puzzle;

  /// The database clock at the time of the call, to keep the on-screen timer in step with the cloud.
  final DateTime serverNow;
  final DateTime? startedAt;
  final Result? result;
}

/// What `start_run` returns.
class RunStart {
  const RunStart({required this.startedAt, required this.serverNow});

  final DateTime startedAt;
  final DateTime serverNow;
}

/// What `submit_guess` returns: a result, or "not this one".
sealed class GuessOutcome {
  const GuessOutcome();
}

class Solved extends GuessOutcome {
  const Solved(this.result);
  final Result result;
}

class Wrong extends GuessOutcome {
  const Wrong();
}
