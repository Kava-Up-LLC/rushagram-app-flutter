import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// DESIGN.md §3 — one family, Rubik.
abstract final class AppText {
  static const _f = 'Rubik';
  static const display = TextStyle(fontFamily: _f, fontSize: 56, height: 60 / 56, fontWeight: FontWeight.w800, color: AppColors.ink,
      fontFeatures: [FontFeature.tabularFigures()]);
  static const tileLetter = TextStyle(fontFamily: _f, fontSize: 34, height: 1, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const title = TextStyle(fontFamily: _f, fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const heading = TextStyle(fontFamily: _f, fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const body = TextStyle(fontFamily: _f, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: AppColors.ink);
  static const label = TextStyle(fontFamily: _f, fontSize: 14, height: 18 / 14, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const timer = TextStyle(fontFamily: _f, fontSize: 22, height: 26 / 22, fontWeight: FontWeight.w700, color: AppColors.onColor,
      fontFeatures: [FontFeature.tabularFigures()]);
}
