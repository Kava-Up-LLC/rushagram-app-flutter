import 'package:flutter_test/flutter_test.dart';
import 'package:rushagram_app/core/errors.dart';
import 'package:rushagram_app/features/daily/daily_controller.dart';

import 'fakes.dart';

DailyController make(FakeRepo repo, {FakeStore? store, FakeAnalytics? analytics, FakePush? push}) => DailyController(
      repository: repo,
      analytics: analytics ?? FakeAnalytics(),
      push: push ?? FakePush(),
      store: store ?? FakeStore(nickname: 'Ana'),
      clock: () => now,
    );

void fill(DailyController c, List<int> order) {
  for (final i in order) {
    c.tapTile(i);
  }
}

void main() {
  test('load → ready with the tiles face down; Start runs the clock', () async {
    final a = FakeAnalytics();
    final c = make(FakeRepo(), analytics: a);
    await c.load();
    expect(c.phase, DailyPhase.ready);
    expect(c.puzzle!.number, 12);
    c.tapTile(0); // nothing before Start
    expect(c.board!.isEmpty, isTrue);
    await c.start();
    expect(c.phase, DailyPhase.running);
    expect(c.elapsed, Duration.zero);
    expect(a.events, ['puzzle_opened', 'run_started']);
  });

  test('a wrong word clears the slots, shakes, and the clock keeps running', () async {
    final repo = FakeRepo();
    final c = make(repo);
    await c.load();
    await c.start();
    fill(c, [0, 1, 2, 3, 4, 5]); // MOTATO
    await pumpEventQueue();
    expect(repo.guesses, ['MOTATO']);
    expect(c.wrongCount, 1);
    expect(c.showWrongLine, isTrue);
    expect(c.board!.isEmpty, isTrue);
    expect(c.phase, DailyPhase.running);
    c.dispose();
  });

  test('the right word: solved with time and rank, and we ask for notifications once', () async {
    final store = FakeStore(nickname: 'Ana');
    final c = make(FakeRepo(), store: store);
    await c.load();
    await c.start();
    fill(c, [2, 1, 0, 3, 4, 5]); // TOMATO
    await pumpEventQueue();
    expect(c.phase, DailyPhase.solved);
    expect(c.result!.rank, 14);
    expect(c.justSolved, isTrue);
    expect(c.askPush, isTrue);
    expect(c.shareText(), 'Rushagram #12 · 0:23 · #14 today');
    await c.answerPush(turnOn: false);
    expect(store.pushAsked, isTrue);
    expect(c.askPush, isFalse);
  });

  test('opening the app again the same day lands on the result', () async {
    final c = make(FakeRepo(started: true, solved: result()));
    await c.load();
    expect(c.phase, DailyPhase.solved);
    expect(c.justSolved, isFalse);
    expect(c.askPush, isFalse);
  });

  test('a run already started picks up where it was (the clock never restarts)', () async {
    final c = make(FakeRepo(started: true));
    await c.load();
    expect(c.phase, DailyPhase.running);
    expect(c.elapsed, const Duration(seconds: 5));
  });

  test('no connection: banner, nothing lost, Retry works', () async {
    final repo = FakeRepo()..failNext = const AppFailure(FailureKind.noConnection);
    final c = make(repo);
    await c.load();
    expect(c.phase, DailyPhase.failed);
    expect(c.failure!.message, 'No connection');
    await c.load();
    expect(c.phase, DailyPhase.ready);
    await c.start();
    fill(c, [2, 1, 0, 3, 4]);
    repo.failNext = const AppFailure(FailureKind.noConnection);
    c.tapTile(5);
    await pumpEventQueue();
    expect(c.failure, isNotNull);
    expect(c.board!.guess, 'TOMATO'); // the guess didn't count; tiles stay
    await c.submit();
    expect(c.phase, DailyPhase.solved);
  });
}
