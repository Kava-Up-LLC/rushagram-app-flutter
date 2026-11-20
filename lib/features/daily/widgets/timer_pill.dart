import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// The clock (amber). It only draws time; the real time is measured in the cloud.
class TimerPill extends StatefulWidget {
  const TimerPill({super.key, required this.elapsed, required this.running});

  final Duration Function() elapsed;
  final bool running;

  @override
  State<TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<TimerPill> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => _shown.value = widget.elapsed());
  final _shown = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TimerPill old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    _shown.value = widget.running ? widget.elapsed() : Duration.zero;
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
  Widget build(BuildContext context) => ValueListenableBuilder<Duration>(
        valueListenable: _shown,
        builder: (context, d, _) {
          final text = formatTime(d.isNegative ? 0 : d.inMilliseconds);
          return Semantics(
            label: 'Timer $text',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(color: widget.running ? AppColors.amber : AppColors.slot, borderRadius: BorderRadius.circular(999)),
              child: Text(text, style: AppText.timer.copyWith(color: widget.running ? AppColors.onColor : AppColors.inkMuted)),
            ),
          );
        },
      );
}
