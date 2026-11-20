import '../../../core/appambit/cloud_service.dart';
import '../../../core/errors.dart';
import '../../../core/local_store.dart';
import 'puzzle.dart';

/// today / start_run / submit_guess / ranking on AppAmbit Cloud Code.
abstract interface class DailyRepository {
  Future<Today> today();
  Future<RunStart> startRun();
  Future<GuessOutcome> submitGuess(String guess);
  Future<Result> ranking();
}

class CloudDailyRepository implements DailyRepository {
  CloudDailyRepository({required this.cloud, required this.store, required this.platform});

  final CloudService cloud;
  final LocalStore store;
  final String platform;

  Map<String, dynamic> _ok(Map<String, dynamic> r) {
    if (r['ok'] == true) return r;
    throw AppFailure(FailureKind.unexpected, r['error']);
  }

  @override
  Future<Today> today() async {
    final r = _ok(await cloud.call('today', {'player_id': store.playerId, 'nickname': store.nickname ?? '', 'platform': platform}));
    final run = r['run'] == null ? null : Map<String, dynamic>.from(r['run'] as Map);
    return Today(
      puzzle: Puzzle(
        day: r['day'] as String,
        number: (r['number'] as num).toInt(),
        letters: (r['letters'] as String).toUpperCase(),
        nextAt: DateTime.parse(r['next_at'] as String),
      ),
      serverNow: DateTime.parse(r['now'] as String),
      startedAt: run == null ? null : DateTime.parse(run['started_at'] as String),
      result: run != null && run['solved'] == true ? Result.fromJson(run) : null,
    );
  }

  @override
  Future<RunStart> startRun() async {
    final r = _ok(await cloud.call('start_run', {'player_id': store.playerId}));
    return RunStart(startedAt: DateTime.parse(r['started_at'] as String), serverNow: DateTime.parse(r['now'] as String));
  }

  @override
  Future<GuessOutcome> submitGuess(String guess) async {
    final r = await cloud.call('submit_guess', {'player_id': store.playerId, 'guess': guess.toLowerCase()});
    if (r['ok'] == true) return Solved(Result.fromJson(r));
    if (r['error'] == 'WRONG') return const Wrong();
    throw AppFailure(FailureKind.unexpected, r['error']);
  }

  @override
  Future<Result> ranking() async => Result.fromJson(_ok(await cloud.call('ranking', {'player_id': store.playerId})));
}
