import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/no_connection_banner.dart';
import '../daily_controller.dart';
import '../widgets/letter_tile.dart';
import '../widgets/timer_pill.dart';

/// Play: before Start (tiles face down) and running (slots + tiles + Shuffle/Clear).
class PlayView extends StatefulWidget {
  const PlayView({super.key, required this.controller, required this.nickname, required this.onTitleLongPress});

  final DailyController controller;
  final String nickname;

  /// The test crash for the video (spec §10).
  final VoidCallback onTitleLongPress;

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> with SingleTickerProviderStateMixin {
  // Created in initState, not lazily: a lazy controller would be created inside dispose() when no word was wrong.
  late final AnimationController _shake;
  late int _seenWrong = widget.controller.wrongCount;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    widget.controller.addListener(_onChange);
  }

  void _onChange() {
    final c = widget.controller;
    if (c.wrongCount != _seenWrong) {
      _seenWrong = c.wrongCount;
      _shake.forward(from: 0);
    }
    if (c.phase == DailyPhase.solved && c.justSolved) {
      final reduce = MediaQuery.disableAnimationsOf(context);
      Future.delayed(Duration(milliseconds: reduce ? 300 : 900), () {
        if (mounted) c.doneCelebrating();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final c = widget.controller;
          final p = c.puzzle!;
          final b = c.board!;
          final running = c.phase == DailyPhase.running || c.phase == DailyPhase.solved;
          final solved = c.phase == DailyPhase.solved;
          return LayoutBuilder(builder: (context, box) {
            final tile = math.min(52.0, (box.maxWidth - 48 - 5 * 8) / 6);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onLongPress: widget.onTitleLongPress,
                          child: Text('Rushagram #${p.number}', style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(widget.nickname, style: AppText.label.copyWith(color: AppColors.inkMuted), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(child: TimerPill(elapsed: () => c.elapsed, running: running && !solved)),
                  const SizedBox(height: 32),
                  if (c.failure != null) ...[
                    NoConnectionBanner(onRetry: c.phase == DailyPhase.ready ? c.start : c.submit),
                    const SizedBox(height: 16),
                  ],
                  if (!running) ...[
                    _row([for (var i = 0; i < 6; i++) LetterTile(letter: null, faceDown: true, size: tile)]),
                    const SizedBox(height: 24),
                    const Text('Same letters for everyone today. The clock starts when you tap Start.', style: AppText.body, textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    StartButton(onPressed: c.start, busy: c.busy),
                  ] else ...[
                    _row([
                      for (var s = 0; s < b.size; s++)
                        _Flip(
                          delay: Duration(milliseconds: 40 * s),
                          on: solved,
                          child: LetterTile(
                            letter: b.slots[s] == null ? null : b.letters[b.slots[s]!],
                            amber: solved,
                            size: tile,
                            onTap: b.slots[s] == null ? null : () => c.untapSlot(s),
                          ),
                        ),
                    ]),
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: c.showWrongLine ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Text('Not this one. Keep going.', style: AppText.body),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _shake,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value), 0),
                        child: child,
                      ),
                      child: _row([
                        for (final i in b.order)
                          LetterTile(
                            letter: b.isUsed(i) ? null : b.letters[i],
                            size: tile,
                            onTap: b.isUsed(i) ? null : () => c.tapTile(i),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: SecondaryButton(label: 'Shuffle', onPressed: solved ? null : c.shuffle)),
                        const SizedBox(width: 12),
                        Expanded(child: SecondaryButton(label: 'Clear', onPressed: solved || b.isEmpty ? null : c.clear)),
                      ],
                    ),
                  ],
                ],
              ),
            );
          });
        },
      );

  Widget _row(List<Widget> children) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      );
}

/// The slots flip to amber one after another when the word is right (DESIGN.md §8).
class _Flip extends StatelessWidget {
  const _Flip({required this.delay, required this.on, required this.child});

  final Duration delay;
  final bool on;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!on || MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260) + delay,
      builder: (context, t, child) {
        final local = ((t * (260 + delay.inMilliseconds) - delay.inMilliseconds) / 260).clamp(0.0, 1.0);
        return Transform(alignment: Alignment.center, transform: Matrix4.rotationX(math.pi * (1 - local) * (local < 1 ? 1 : 0)), child: child);
      },
      child: child,
    );
  }
}
