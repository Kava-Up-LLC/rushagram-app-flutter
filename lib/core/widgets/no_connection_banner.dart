import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'sticker.dart';

/// "No connection" + Retry, as a white sticker (DESIGN.md §5). Online only: nothing is saved for later.
class NoConnectionBanner extends StatelessWidget {
  const NoConnectionBanner({super.key, required this.onRetry, this.message = 'No connection'});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => Sticker(
        fill: AppColors.tile,
        drop: 4,
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.ink, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: AppText.label.copyWith(fontSize: 16))),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.indigo, textStyle: AppText.label.copyWith(fontSize: 16)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
