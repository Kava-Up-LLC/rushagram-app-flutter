import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'sticker.dart';

/// The race button: amber, full width, ink text and icon (Start, Let's play). DESIGN.md §5.
class BigButton extends StatelessWidget {
  const BigButton({super.key, required this.label, required this.icon, required this.onPressed, this.busy = false});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Sticker(
          fill: AppColors.amber,
          radius: 18,
          drop: 6,
          onTap: busy ? null : onPressed,
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(
              child: busy
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.ink))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, color: AppColors.ink, size: 26),
                      const SizedBox(width: 10),
                      Text(label, style: AppText.button),
                    ]),
            ),
          ),
        ),
      );
}

/// White sticker button (Shuffle, Clear, Not now). Faded when disabled.
class WhiteButton extends StatelessWidget {
  const WhiteButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        excludeSemantics: true,
        child: Opacity(
          opacity: onPressed == null ? 0.5 : 1,
          child: Sticker(
            fill: AppColors.tile,
            onTap: onPressed,
            child: SizedBox(
              height: 48,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, color: AppColors.ink, size: 22), const SizedBox(width: 8)],
                Text(label, style: AppText.button.copyWith(fontSize: 17)),
              ]),
            ),
          ),
        ),
      );
}

/// Indigo sticker button with white text (Share my time, Turn on).
class IndigoButton extends StatelessWidget {
  const IndigoButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 54});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Sticker(
          fill: AppColors.indigo,
          radius: 18,
          drop: 6,
          onTap: onPressed,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (icon != null) ...[Icon(icon, color: AppColors.onColor, size: 22), const SizedBox(width: 10)],
              Text(label, style: AppText.button.copyWith(fontSize: 20, color: AppColors.onColor)),
            ]),
          ),
        ),
      );
}
