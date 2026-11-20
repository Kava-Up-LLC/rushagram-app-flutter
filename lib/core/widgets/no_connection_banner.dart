import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// "No connection" + Retry (DESIGN.md §5). Online only: nothing is saved for later.
class NoConnectionBanner extends StatelessWidget {
  const NoConnectionBanner({super.key, required this.onRetry, this.message = 'No connection'});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(color: AppColors.butter, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(child: Text(message, style: AppText.label)),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.indigo, textStyle: AppText.label),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
