import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/no_connection_banner.dart';
import '../../../core/widgets/sticker.dart';
import '../daily_controller.dart';
import '../widgets/letter_tile.dart';
import '../widgets/stopwatch.dart';
import '../widgets/top_bar.dart';

/// Play: before Start (tiles face down) and running (slots + tray + Shuffle/Clear). DESIGN.md §6.
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

  // A small tilt per tray position, so the tiles look placed by hand.
  static const _tilts = [-0.008, 0.006, -0.005, 0.008, -0.008, 0.006];

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
      if (!MediaQuery.disableAnimationsOf(context)) _shake.forward(from: 0);
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
          final nextFree = b.slots.indexOf(null);
          return LayoutBuilder(builder: (context, box) {
            final tile = math.min(50.0, (box.maxWidth - 40 - 6 - 5 * 8) / 6);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TopBar(number: p.number, nickname: widget.nickname, onTitleLongPress: widget.onTitleLongPress),
                        if (c.failure != null) ...[
                          const SizedBox(height: 14),
                          NoConnectionBanner(onRetry: c.phase == DailyPhase.ready ? c.start : c.submit),
                        ],
                        const SizedBox(height: 22),
                        Center(child: GameStopwatch(elapsed: () => c.elapsed, running: running && !solved)),
                        const SizedBox(height: 28),
                        _row([
                          for (var s = 0; s < b.size; s++)
                            if (!running)
                              LetterTile(look: TileLook.slot, size: tile)
                            else if (b.slots[s] == null)
                              LetterTile(look: s == nextFree && !solved ? TileLook.nextSlot : TileLook.slot, size: tile)
                            else
                              _Flip(
                                delay: Duration(milliseconds: 40 * s),
                                on: solved,
                                child: LetterTile(
                                  look: solved ? TileLook.amber : TileLook.letter,
                                  letter: b.letters[b.slots[s]!],
                                  size: tile,
                                  onTap: solved ? null : () => c.untapSlot(s),
                                ),
                              ),
                        ]),
                        SizedBox(
                          height: 62,
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: c.showWrongLine ? 1 : 0,
                              duration: const Duration(milliseconds: 150),
                              child: c.showWrongLine ? const _Bubble(text: 'Not this one. Keep going.') : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _shake,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value), 0),
                            child: child,
                          ),
                          child: Sticker(
                            fill: AppColors.indigo,
                            radius: 20,
                            padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                            child: _row([
                              for (var k = 0; k < b.size; k++)
                                if (!running)
                                  LetterTile(look: TileLook.faceDown, size: tile, tilt: _tilts[k] * 0.6)
                                else if (b.isUsed(b.order[k]))
                                  LetterTile(look: TileLook.used, size: tile)
                                else
                                  LetterTile(
                                    look: TileLook.letter,
                                    letter: b.letters[b.order[k]],
                                    size: tile,
                                    tilt: _tilts[k],
                                    onTap: () => c.tapTile(b.order[k]),
                                  ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          running ? 'Tap a letter to place it. Tap a placed one to send it back.' : 'Same letters for everyone today. The clock starts when you tap Start.',
                          style: AppText.body.copyWith(fontSize: 15, color: running ? AppColors.inkMuted : AppColors.ink),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        if (!running)
                          BigButton(label: 'Start', icon: Icons.timer_outlined, onPressed: c.start, busy: c.busy)
                        else
                          Row(
                            children: [
                              Expanded(child: WhiteButton(label: 'Shuffle', icon: Icons.shuffle_rounded, onPressed: solved ? null : c.shuffle)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: WhiteButton(label: 'Clear', icon: Icons.backspace_outlined, onPressed: solved || b.isEmpty ? null : c.clear),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
        },
      );

  Widget _row(List<Widget> children) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
        ],
      );
}

/// "Not this one. Keep going." in a speech bubble pointing at the slots (DESIGN.md §5).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Sticker(
            fill: AppColors.tile,
            drop: 4,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(text, style: AppText.heading),
          ),
          // The tail: a white square turned 45°, with the outline on its two top sides.
          Positioned(
            top: -7,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.tile,
                  border: Border(top: BorderSide(color: AppColors.ink, width: 3), left: BorderSide(color: AppColors.ink, width: 3)),
                ),
              ),
            ),
          ),
        ],
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
