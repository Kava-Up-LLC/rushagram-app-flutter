import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rushagram_app/app.dart';
import 'package:rushagram_app/app_services.dart';
import 'package:rushagram_app/core/appambit/cloud_service.dart';

import 'fakes.dart';

class NoCloud implements CloudService {
  @override
  Future<Map<String, dynamic>> call(String function, Map<String, dynamic> body) => throw UnimplementedError();
}

AppServices services({FakeStore? store, FakeRepo? repo, List<String>? shared, FakeDiagnostics? diag}) => AppServices(
      cloud: NoCloud(),
      analytics: FakeAnalytics(),
      push: FakePush(),
      diagnostics: diag ?? FakeDiagnostics(),
      store: store ?? FakeStore(),
      platform: 'ios',
      share: (t) async => shared?.add(t),
      daily: repo ?? FakeRepo(),
    );

void main() {
  testWidgets('first open: nickname, then play', (tester) async {
    await tester.pumpWidget(App(services: services()));
    expect(find.text('Rushagram'), findsOneWidget);
    expect(find.text('One word a day. Everyone gets the same letters.'), findsOneWidget);
    await tester.tap(find.text("Let's play"));
    await tester.pump();
    expect(find.text('Use 2 to 16 letters or numbers.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.tap(find.text("Let's play"));
    await tester.pumpAndSettle();
    expect(find.text('Rushagram #12'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Same letters for everyone today. The clock starts when you tap Start.'), findsOneWidget);
  });

  testWidgets('play: Start, a wrong word, then the right one shows the result', (tester) async {
    final shared = <String>[];
    final diag = FakeDiagnostics();
    await tester.pumpWidget(App(services: services(store: FakeStore(nickname: 'Ana'), shared: shared, diag: diag)));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Rushagram #12'));
    expect(diag.crashes, 1);
    await tester.tap(find.text('Start'));
    await tester.pump();
    for (final l in ['M', 'O', 'T', 'A', 'T', 'O']) {
      await tester.tap(find.text(l).last);
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Not this one. Keep going.'), findsOneWidget);
    for (final l in ['T', 'O', 'M', 'A', 'T', 'O']) {
      await tester.tap(find.text(l).last);
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Solved in'), findsOneWidget);
    expect(find.text('0:23'), findsNWidgets(2)); // the Solved card + your row, added below the top 20
    expect(find.text('Top 20 today'), findsOneWidget);
    expect(find.text("Get a nudge when tomorrow's word is ready?"), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Share'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Share'));
    expect(shared, ['Rushagram #12 · 0:23 · #14 today']);
  });

  testWidgets('already played today: lands on the result', (tester) async {
    await tester.pumpWidget(App(services: services(store: FakeStore(nickname: 'Ana'), repo: FakeRepo(started: true, solved: result()))));
    await tester.pumpAndSettle();
    expect(find.text("You've played today's Rushagram."), findsOneWidget);
    expect(find.textContaining('Next Rushagram in'), findsOneWidget);
  });
}
