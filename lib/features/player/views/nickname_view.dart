import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/buttons.dart';
import '../../daily/widgets/letter_tile.dart';
import '../player_controller.dart';

/// First open: pick a nickname, then play.
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

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  const Text('Rushagram', style: AppText.title),
                  const SizedBox(height: 8),
                  const Text('One word a day. Everyone gets the same letters.', style: AppText.body),
                  const SizedBox(height: 32),
                  // Decoration: R U S H · ·
                  ExcludeSemantics(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final size = math.min(52.0, (box.maxWidth - 5 * 8) / 6);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [for (final c in 'RUSH  '.split('')) LetterTile(letter: c.trim().isEmpty ? null : c, size: size)],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(controller: _field, hint: 'Your nickname', onSubmitted: (_) => _go()),
                  if (widget.controller.error != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.controller.error!, style: AppText.label.copyWith(color: AppColors.ink)),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(label: "Let's play", onPressed: _go),
                ],
              ),
            ),
          ),
        ),
      );
}
