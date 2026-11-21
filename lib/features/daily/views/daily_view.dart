import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/no_connection_banner.dart';
import '../daily_controller.dart';
import 'play_view.dart';
import 'result_view.dart';

/// Today's Rushagram: Play until solved, then the Result. Reloads when the app comes back
/// (the puzzle changes at 00:00 UTC) or a notification is tapped.
class DailyView extends StatefulWidget {
  const DailyView({super.key, required this.controller, required this.nickname, required this.onShare, required this.onTestCrash});

  final DailyController controller;
  final String nickname;
  final void Function(String text) onShare;
  final VoidCallback onTestCrash;

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  late final AppLifecycleListener _life;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
    _life = AppLifecycleListener(onResume: () {
      final c = widget.controller;
      // Back from the background: pick up a new day, or retry after a failure. Mid-run, keep the board.
      if (c.phase != DailyPhase.running && !c.busy) c.load();
    });
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final c = widget.controller;
              return switch (c.phase) {
                DailyPhase.loading => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
                DailyPhase.failed => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Image.asset('assets/branding/mark.png', height: 72, excludeFromSemantics: true),
                        const SizedBox(height: 12),
                        const Text('Rushagram', style: AppText.hero, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        NoConnectionBanner(onRetry: c.load, message: c.failure?.message ?? 'No connection'),
                      ],
                    ),
                  ),
                DailyPhase.solved when !c.justSolved =>
                  ResultView(controller: c, nickname: widget.nickname, onShare: widget.onShare, onTitleLongPress: widget.onTestCrash),
                _ => PlayView(controller: c, nickname: widget.nickname, onTitleLongPress: widget.onTestCrash),
              };
            },
          ),
        ),
      );
}
