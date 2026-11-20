import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/buttons.dart';
import '../daily_controller.dart';
import '../widgets/rank_list.dart';

/// Result: your time, your rank today, the top 20, Share, and when the next puzzle comes.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.controller, required this.nickname, required this.onShare, required this.onTitleLongPress});

  final DailyController controller;
  final String nickname;
  final void Function(String text) onShare;
  final VoidCallback onTitleLongPress;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final r = controller.result!;
          final p = controller.puzzle!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              GestureDetector(onLongPress: onTitleLongPress, child: Text('Rushagram #${p.number}', style: AppText.title)),
              if (!controller.justSolvedThisSession) ...[
                const SizedBox(height: 4),
                Text("You've played today's Rushagram.", style: AppText.body.copyWith(color: AppColors.inkMuted)),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: AppColors.edge, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solved in', style: AppText.heading.copyWith(color: AppColors.inkMuted)),
                    Text(formatTime(r.timeMs), style: AppText.display),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(style: AppText.heading, children: [
                      TextSpan(text: '#${r.rank}', style: const TextStyle(color: AppColors.amber)),
                      TextSpan(text: ' of ${r.total} today'),
                    ])),
                  ],
                ),
              ),
              if (controller.askPush) ...[
                const SizedBox(height: 16),
                _PushAsk(onAnswer: (on) => controller.answerPush(turnOn: on)),
              ],
              const SizedBox(height: 32),
              const Text('Top 20 today', style: AppText.heading),
              const SizedBox(height: 8),
              RankList(result: r, nickname: nickname),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Share',
                onPressed: () {
                  final text = controller.shareText();
                  if (text != null) onShare(text);
                },
              ),
              const SizedBox(height: 16),
              Text('Next Rushagram in ${formatCountdown(controller.nextIn)}',
                  style: AppText.body.copyWith(color: AppColors.inkMuted), textAlign: TextAlign.center),
            ],
          );
        },
      );
}

class _PushAsk extends StatelessWidget {
  const _PushAsk({required this.onAnswer});
  final void Function(bool turnOn) onAnswer;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tile,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.edge, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Get a nudge when tomorrow's word is ready?", style: AppText.body),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: SecondaryButton(label: 'Not now', onPressed: () => onAnswer(false))),
              const SizedBox(width: 12),
              Expanded(child: PrimaryButton(label: 'Turn on', onPressed: () => onAnswer(true))),
            ]),
          ],
        ),
      );
}
