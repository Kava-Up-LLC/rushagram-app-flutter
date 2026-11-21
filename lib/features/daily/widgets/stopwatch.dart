import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// The stopwatch (DESIGN.md §5). It only draws time; the real time is measured in the cloud.
/// Running: an amber slice and a needle go round once a minute. At rest: "0:00".
class GameStopwatch extends StatefulWidget {
  const GameStopwatch({super.key, required this.elapsed, required this.running, this.size = 200});

  final Duration Function() elapsed;
  final bool running;
  final double size;

  @override
  State<GameStopwatch> createState() => _StopwatchState();
}

class _StopwatchState extends State<GameStopwatch> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => _shown.value = _now());
  final _shown = ValueNotifier(Duration.zero);

  Duration _now() {
    final d = widget.elapsed();
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(GameStopwatch old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    _shown.value = widget.running ? _now() : Duration.zero;
    if (widget.running && !_ticker.isActive) _ticker.start();
    if (!widget.running && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final running = widget.running;
    return ValueListenableBuilder<Duration>(
      valueListenable: _shown,
      builder: (context, d, _) {
        final text = formatTime(d.inMilliseconds);
        return Semantics(
          label: 'Timer $text',
          excludeSemantics: true,
          child: SizedBox(
            width: s,
            height: s + 34,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Crown and stem.
                Positioned(
                  top: 0,
                  child: Container(
                    width: 32,
                    height: 18,
                    decoration: BoxDecoration(
                      color: running ? AppColors.amber : AppColors.ink,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.ink, width: 3),
                    ),
                  ),
                ),
                Positioned(top: 16, child: Container(width: 10, height: 14, color: AppColors.ink)),
                // The dial.
                Positioned(
                  top: 26,
                  child: Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      color: AppColors.tile,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 4),
                      boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 7))],
                    ),
                    child: CustomPaint(
                      painter: _DialPainter(seconds: d.inMilliseconds / 1000, running: running),
                      child: running
                          ? Align(
                              alignment: const Alignment(0, 0.55),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.tile,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.ink, width: 3),
                                ),
                                child: Text(text, style: AppText.clock),
                              ),
                            )
                          : Center(child: Text(text, style: AppText.clock.copyWith(fontSize: 52, color: AppColors.slotEdge))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.seconds, required this.running});

  final double seconds;
  final bool running;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final turn = (seconds % 60) / 60;
    const start = -math.pi / 2;
    if (running && turn > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r - 4), start, turn * 2 * math.pi, true, Paint()..color = AppColors.amberSoft);
    }
    final tick = Paint()
      ..color = running ? AppColors.ink : AppColors.slotEdge
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final a = start + i * math.pi / 6;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r - 16), c + dir * (r - 6), tick);
    }
    if (!running) return;
    final a = start + turn * 2 * math.pi;
    canvas.drawLine(
      c,
      c + Offset(math.cos(a), math.sin(a)) * (r - 12),
      Paint()
        ..color = AppColors.amberDeep
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 7, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.seconds != seconds || old.running != running;
}
