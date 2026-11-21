import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/sticker.dart';
import '../daily_controller.dart';
import '../widgets/letter_tile.dart';
import '../widgets/rank_list.dart';

/// Result: "Solved!", your time and rank, the top 20, Share, and when the next word comes. DESIGN.md §6.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.controller, required this.nickname, required this.onShare, required this.onTitleLongPress});

  final DailyController controller;
  final String nickname;
  final void Function(String text) onShare;
  final VoidCallback onTitleLongPress;

  static const _tilts = [-0.011, 0.008, -0.006, 0.011, -0.008, 0.006];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final r = controller.result!;
          final p = controller.puzzle!;
          // The word is only known on the phone right after solving (the cloud never sends it).
          final word = controller.justSolvedThisSession ? controller.board?.guess : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onLongPress: onTitleLongPress,
                    child: Sticker(
                      fill: AppColors.tile,
                      radius: 10,
                      drop: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Text('Rushagram #${p.number}', style: AppText.label),
                    ),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(nickname, style: AppText.label.copyWith(color: AppColors.inkMuted), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              if (!controller.justSolvedThisSession) ...[
                const SizedBox(height: 10),
                Text("You've played today's Rushagram.", style: AppText.body.copyWith(color: AppColors.inkMuted)),
              ],
              const SizedBox(height: 18),
              const Center(child: _Ribbon(text: 'Solved!')),
              if (word != null && word.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < word.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      LetterTile(look: TileLook.amber, letter: word[i], size: 46, tilt: _tilts[i % _tilts.length]),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Transform.rotate(
                      angle: -0.026,
                      child: Sticker(
                        fill: AppColors.amber,
                        radius: 18,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Your time', style: AppText.label.copyWith(fontSize: 13)),
                          Text(formatTime(r.timeMs), style: AppText.bigNumber),
                          const SizedBox(height: 17),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Transform.rotate(
                      angle: 0.026,
                      child: Sticker(
                        fill: AppColors.tile,
                        radius: 18,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Rank today', style: AppText.label.copyWith(fontSize: 13)),
                          Text('#${r.rank}', style: AppText.bigNumber),
                          Text('of ${r.total} today', style: AppText.label.copyWith(fontSize: 13, color: AppColors.inkMuted)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.askPush) ...[
                const SizedBox(height: 16),
                _PushAsk(onAnswer: (on) => controller.answerPush(turnOn: on)),
              ],
              const SizedBox(height: 18),
              Sticker(
                fill: AppColors.tile,
                radius: 20,
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 6), child: Text('Top 20 today', style: AppText.heading)),
                    RankList(result: r, nickname: nickname),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              IndigoButton(
                label: 'Share my time',
                icon: Icons.ios_share_rounded,
                height: 54,
                onPressed: () {
                  final text = controller.shareText();
                  if (text != null) onShare(text);
                },
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: AppText.body.copyWith(fontSize: 14, color: AppColors.inkMuted),
                  children: [
                    const TextSpan(text: 'Next word in '),
                    TextSpan(text: formatCountdown(controller.nextIn), style: AppText.label.copyWith(fontSize: 14)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      );
}

/// The "Solved!" ribbon: an indigo sticker with two folded ends behind it.
class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 16), child: CustomPaint(size: Size(24, 38), painter: _RibbonEnd(left: true))),
          Sticker(
            fill: AppColors.indigo,
            radius: 10,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(text, style: AppText.banner),
          ),
          const Padding(padding: EdgeInsets.only(top: 16), child: CustomPaint(size: Size(24, 38), painter: _RibbonEnd(left: false))),
        ],
      );
}

class _RibbonEnd extends CustomPainter {
  const _RibbonEnd({required this.left});
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = left
        ? (Path()
          ..moveTo(w + 4, 0)
          ..lineTo(0, 0)
          ..lineTo(w * 0.4, h / 2)
          ..lineTo(0, h)
          ..lineTo(w + 4, h))
        : (Path()
          ..moveTo(-4, 0)
          ..lineTo(w, 0)
          ..lineTo(w * 0.6, h / 2)
          ..lineTo(w, h)
          ..lineTo(-4, h));
    canvas.drawPath(path, Paint()..color = AppColors.indigoDark);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_RibbonEnd old) => old.left != left;
}

class _PushAsk extends StatelessWidget {
  const _PushAsk({required this.onAnswer});
  final void Function(bool turnOn) onAnswer;

  @override
  Widget build(BuildContext context) => Sticker(
        fill: AppColors.tile,
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.notifications_active_outlined, color: AppColors.ink, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text("Get a nudge when tomorrow's word is ready?", style: AppText.body.copyWith(fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: WhiteButton(label: 'Not now', onPressed: () => onAnswer(false))),
              const SizedBox(width: 12),
              Expanded(child: IndigoButton(label: 'Turn on', height: 47, onPressed: () => onAnswer(true))),
            ]),
          ],
        ),
      );
}
