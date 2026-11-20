import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// White field with the hard edge drop (DESIGN.md §5).
class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.hint, this.onSubmitted, this.maxLength = 16});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final int maxLength;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.tile,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: AppColors.edge, offset: Offset(0, 3))],
        ),
        child: TextField(
          controller: controller,
          maxLength: maxLength,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          onSubmitted: onSubmitted,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.inkMuted),
            counterText: '',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
}
