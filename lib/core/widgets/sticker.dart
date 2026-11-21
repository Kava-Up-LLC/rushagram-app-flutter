import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// DESIGN.md §4: a piece with a 3 px ink outline and a solid ink drop (no blur).
/// Pressable when [onTap] is set: it moves down 3 px and the drop shrinks to 2 px.
class Sticker extends StatefulWidget {
  const Sticker({
    super.key,
    required this.fill,
    required this.child,
    this.radius = 16,
    this.drop = 5,
    this.outline = 3,
    this.onTap,
    this.padding,
  });

  final Color fill;
  final Widget child;
  final double radius;
  final double drop;
  final double outline;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  State<Sticker> createState() => _StickerState();
}

class _StickerState extends State<Sticker> {
  bool _down = false; // press feedback only, not app data

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final pressed = _down && enabled;
    final drop = pressed ? 2.0 : widget.drop;
    return Padding(
      // Room for the drop, so it never overlaps what sits below.
      padding: EdgeInsets.only(bottom: widget.drop),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          transform: Matrix4.translationValues(0, pressed ? widget.drop - 2 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.fill,
            borderRadius: BorderRadius.circular(widget.radius),
            border: widget.outline > 0 ? Border.all(color: AppColors.ink, width: widget.outline) : null,
            boxShadow: [BoxShadow(color: AppColors.ink, offset: Offset(0, drop))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
