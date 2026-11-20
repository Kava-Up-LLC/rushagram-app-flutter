import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'hard_drop.dart';

/// Indigo, full width, 52 high (Let's play, Share).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: HardDrop(
          fill: onPressed == null ? AppColors.inkMuted : AppColors.indigo,
          drop: AppColors.indigoDeep,
          radius: 14,
          onTap: busy ? null : onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Center(
              child: busy
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onColor))
                  : Text(label, style: AppText.label.copyWith(fontSize: 16, color: AppColors.onColor)),
            ),
          ),
        ),
      );
}

/// The clock's button: amber, full width, 56 high, "Start" Bold 20.
class StartButton extends StatelessWidget {
  const StartButton({super.key, required this.onPressed, this.busy = false});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Start',
        child: HardDrop(
          fill: AppColors.amber,
          drop: AppColors.amberDeep,
          radius: 14,
          onTap: busy ? null : onPressed,
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Center(
              child: busy
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onColor))
                  : Text('Start', style: AppText.heading.copyWith(color: AppColors.onColor)),
            ),
          ),
        ),
      );
}

/// White with an indigo border (Shuffle, Clear, Not now).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: HardDrop(
          fill: AppColors.tile,
          drop: AppColors.edge,
          radius: 14,
          border: Border.all(color: AppColors.indigo, width: 2),
          onTap: onPressed,
          child: SizedBox(height: 48, child: Center(child: Text(label, style: AppText.label.copyWith(color: AppColors.indigo)))),
        ),
      );
}
