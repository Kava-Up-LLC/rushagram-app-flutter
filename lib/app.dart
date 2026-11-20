import 'package:flutter/material.dart';

import 'app_services.dart';
import 'core/theme/app_theme.dart';
import 'features/daily/daily_controller.dart';
import 'features/daily/views/daily_view.dart';
import 'features/player/player_controller.dart';
import 'features/player/views/nickname_view.dart';

class App extends StatefulWidget {
  const App({super.key, required this.services});

  final AppServices services;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _nav = GlobalKey<NavigatorState>();
  late final _player = PlayerController(store: widget.services.store, analytics: widget.services.analytics);
  late final _daily = DailyController(
    repository: widget.services.daily,
    analytics: widget.services.analytics,
    push: widget.services.push,
    store: widget.services.store,
  );

  @override
  void initState() {
    super.initState();
    // Tapping "Today's Rushagram is ready." opens today's puzzle.
    widget.services.push.onOpened((data) {
      widget.services.analytics.track('push_opened');
      if (widget.services.store.nickname != null) _daily.load();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _daily.dispose();
    super.dispose();
  }

  Widget _dailyView() => DailyView(
        controller: _daily,
        nickname: widget.services.store.nickname ?? '',
        onShare: widget.services.share,
        onTestCrash: widget.services.diagnostics.testCrash,
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Rushagram',
        navigatorKey: _nav,
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: widget.services.store.nickname == null
            ? NicknameView(
                controller: _player,
                onDone: () => _nav.currentState!.pushReplacement(MaterialPageRoute<void>(builder: (_) => _dailyView())),
              )
            : _dailyView(),
      );
}
