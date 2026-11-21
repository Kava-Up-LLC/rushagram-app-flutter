import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/sticker.dart';

/// The game's top bar (DESIGN.md §5): puzzle number, "Rushagram", nickname.
/// Long-pressing "Rushagram" is the test crash (spec §10); nothing in the UI mentions it.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.number, required this.nickname, required this.onTitleLongPress});

  final int number;
  final String nickname;
  final VoidCallback onTitleLongPress;

  @override
  Widget build(BuildContext context) => Sticker(
        fill: AppColors.indigo,
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Text('#$number', style: AppText.label),
            ),
            Expanded(
              child: GestureDetector(
                onLongPress: onTitleLongPress,
                child: Text('Rushagram', textAlign: TextAlign.center, style: AppText.heading.copyWith(fontSize: 18, color: AppColors.onColor)),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(nickname, style: AppText.label.copyWith(color: AppColors.onColor), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}
