import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// DESIGN.md §9. Buttons are our own widgets (core/widgets), so Material shadows stay off.
ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Rubik',
      scaffoldBackgroundColor: AppColors.board,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.indigo, surface: AppColors.board, primary: AppColors.indigo),
      textTheme: const TextTheme(bodyMedium: AppText.body, bodyLarge: AppText.body, titleLarge: AppText.title),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.indigo),
      splashFactory: NoSplash.splashFactory,
    );
