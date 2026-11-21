import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/sticker.dart';
import '../player_controller.dart';

/// First open, the lobby (DESIGN.md §6): the logo, how it plays, pick a nickname, then play.
class NicknameView extends StatefulWidget {
  const NicknameView({super.key, required this.controller, required this.onDone});

  final PlayerController controller;
  final VoidCallback onDone;

  @override
  State<NicknameView> createState() => _NicknameViewState();
}

class _NicknameViewState extends State<NicknameView> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    if (await widget.controller.save(_field.text)) widget.onDone();
  }

  /// Time to 00:00 UTC, when the word changes. The phone clock is fine here: it is only the on-screen countdown.
  static String _nextWordIn() {
    final now = DateTime.now().toUtc();
    final next = DateTime.utc(now.year, now.month, now.day + 1);
    return formatCountdown(next.difference(now));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          // Anchored at the bottom: when the keyboard opens, "Let's play" stays visible above it.
          child: CustomScrollView(
            reverse: true,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/branding/mark.png', height: 92, excludeFromSemantics: true),
                        const SizedBox(height: 14),
                        const Text('Rushagram', style: AppText.hero, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Center(
                          child: Transform.rotate(
                            angle: -0.035,
                            child: Sticker(
                              fill: AppColors.tile,
                              radius: 999,
                              drop: 4,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Text.rich(
                                TextSpan(style: AppText.label.copyWith(fontSize: 15), children: [
                                  const TextSpan(text: 'Daily word  ·  '),
                                  TextSpan(
                                    text: 'new word in ${_nextWordIn()}',
                                    style: AppText.label.copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.inkMuted),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Sticker(
                          fill: AppColors.tile,
                          radius: 20,
                          drop: 6,
                          padding: EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('How it plays', style: AppText.heading),
                              SizedBox(height: 14),
                              _Step(n: 1, text: 'Tap Start. The clock begins.'),
                              SizedBox(height: 12),
                              _Step(n: 2, text: 'Build the 6-letter word from the tiles.'),
                              SizedBox(height: 12),
                              _Step(n: 3, text: "Beat everyone's time. One try a day.", amber: true),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        const Text('Your player name', style: AppText.label),
                        const SizedBox(height: 6),
                        AppTextField(controller: _field, hint: 'Your nickname', onSubmitted: (_) => _go()),
                        if (widget.controller.error != null) ...[
                          const SizedBox(height: 4),
                          Text(widget.controller.error!, style: AppText.label),
                        ],
                        const SizedBox(height: 14),
                        BigButton(label: "Let's play", icon: Icons.play_arrow_rounded, onPressed: _go),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text, this.amber = false});

  final int n;
  final String text;
  final bool amber;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: amber ? AppColors.amber : AppColors.tile,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.ink, width: 3),
              boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 3))],
            ),
            child: Text('$n', style: AppText.label.copyWith(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 15, height: 1.35))),
        ],
      );
}
