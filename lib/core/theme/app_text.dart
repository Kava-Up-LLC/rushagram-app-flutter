import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// DESIGN.md §3 — one family, Rubik. Headings and numbers use ExtraBold (800).
abstract final class AppText {
  static const _f = 'Rubik';
  static const _tabular = [FontFeature.tabularFigures()];
  static const hero = TextStyle(fontFamily: _f, fontSize: 40, height: 1.1, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.8);
  static const banner = TextStyle(fontFamily: _f, fontSize: 32, height: 1.15, fontWeight: FontWeight.w800, color: AppColors.onColor);
  static const bigNumber = TextStyle(fontFamily: _f, fontSize: 46, height: 1.1, fontWeight: FontWeight.w800, color: AppColors.ink,
      letterSpacing: -0.9, fontFeatures: _tabular);
  static const clock = TextStyle(fontFamily: _f, fontSize: 34, height: 1.25, fontWeight: FontWeight.w800, color: AppColors.ink,
      fontFeatures: _tabular);
  static const tileLetter = TextStyle(fontFamily: _f, fontSize: 26, height: 1, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const button = TextStyle(fontFamily: _f, fontSize: 22, height: 1.2, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const heading = TextStyle(fontFamily: _f, fontSize: 17, height: 1.3, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const body = TextStyle(fontFamily: _f, fontSize: 16, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.ink);
  static const label = TextStyle(fontFamily: _f, fontSize: 14, height: 1.3, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const time = TextStyle(fontFamily: _f, fontSize: 16, height: 1.2, fontWeight: FontWeight.w800, color: AppColors.ink,
      fontFeatures: _tabular);
}
