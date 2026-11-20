import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// 52×52 tile (DESIGN.md §5). No letter = an empty spot (slot fill, no drop).
class LetterTile extends StatelessWidget {
  const LetterTile({super.key, required this.letter, this.onTap, this.size = 52, this.amber = false, this.faceDown = false});

  final String? letter;
  final VoidCallback? onTap;
  final double size;
  final bool amber;
  final bool faceDown;

  @override
  Widget build(BuildContext context) {
    final empty = letter == null || faceDown;
    final fill = amber ? AppColors.amber : (empty ? AppColors.slot : AppColors.tile);
    return Semantics(
      button: onTap != null,
      label: empty ? 'Empty' : letter,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            boxShadow: empty && !amber ? null : [BoxShadow(color: amber ? AppColors.amberDeep : AppColors.edge, offset: const Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: empty ? null : Text(letter!, style: AppText.tileLetter.copyWith(fontSize: size * 0.62, color: amber ? AppColors.onColor : AppColors.ink)),
        ),
      ),
    );
  }
}
