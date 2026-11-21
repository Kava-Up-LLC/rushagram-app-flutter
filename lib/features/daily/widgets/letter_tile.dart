import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/dashed_box.dart';
import '../../../core/widgets/sticker.dart';

/// How a tile spot looks (DESIGN.md §5).
enum TileLook {
  /// A white letter tile.
  letter,

  /// A solved letter: amber.
  amber,

  /// Before Start: indigo, with a "?".
  faceDown,

  /// An empty answer slot (dashed).
  slot,

  /// The next free answer slot (solid outline).
  nextSlot,

  /// A tray spot whose letter is in a slot (dashed, on indigo).
  used,
}

/// One 50×50 tile spot. Every look takes the same height (tile + its 4 px drop), so rows line up.
class LetterTile extends StatelessWidget {
  const LetterTile({super.key, required this.look, this.letter, this.onTap, this.size = 50, this.tilt = 0});

  final TileLook look;
  final String? letter;
  final VoidCallback? onTap;
  final double size;

  /// Turns, e.g. 0.008 ≈ 3°. Only for tiles in the tray and solved tiles.
  final double tilt;

  static const _drop = 4.0;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (look) {
      TileLook.letter || TileLook.amber => Sticker(
          fill: look == TileLook.amber ? AppColors.amber : AppColors.tile,
          radius: 10,
          drop: _drop,
          onTap: onTap,
          child: SizedBox.square(
            dimension: size - 6,
            child: Center(child: Text(letter ?? '', style: AppText.tileLetter.copyWith(fontSize: size * 0.52))),
          ),
        ),
      TileLook.faceDown => Sticker(
          fill: AppColors.indigoLight,
          radius: 10,
          drop: _drop,
          child: SizedBox.square(
            dimension: size - 6,
            child: Center(child: Text('?', style: AppText.tileLetter.copyWith(fontSize: size * 0.44, color: AppColors.onIndigoMuted))),
          ),
        ),
      TileLook.slot => Padding(
          padding: const EdgeInsets.only(bottom: _drop),
          child: DashedBox(size: size, fill: AppColors.slot, edge: AppColors.slotEdge),
        ),
      TileLook.nextSlot => Padding(
          padding: const EdgeInsets.only(bottom: _drop),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.ink, width: 3),
            ),
          ),
        ),
      TileLook.used => Padding(
          padding: const EdgeInsets.only(bottom: _drop),
          child: DashedBox(size: size, fill: AppColors.indigoDark, edge: AppColors.indigoLight),
        ),
    };
    final hasLetter = look == TileLook.letter || look == TileLook.amber;
    return Semantics(
      button: onTap != null,
      label: hasLetter ? letter : 'Empty',
      child: tilt == 0 ? child : RotationTransition(turns: AlwaysStoppedAnimation(tilt), child: child),
    );
  }
}
