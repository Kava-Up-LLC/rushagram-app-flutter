import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'sticker.dart';

/// White sticker field, 56 high (DESIGN.md §5).
class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, required this.hint, this.onSubmitted, this.maxLength = 16});

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final int maxLength;

  @override
  Widget build(BuildContext context) => Sticker(
        fill: AppColors.tile,
        drop: 4,
        child: SizedBox(
          height: 50,
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            onSubmitted: onSubmitted,
            style: AppText.button.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body.copyWith(fontSize: 18, color: AppColors.inkMuted),
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      );
}
