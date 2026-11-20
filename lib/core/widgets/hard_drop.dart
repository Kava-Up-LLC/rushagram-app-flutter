import 'package:flutter/material.dart';

/// DESIGN.md §4: a hard 3 px drop with no blur. Pressed: moves down 2 px and the drop shrinks to 1 px.
class HardDrop extends StatefulWidget {
  const HardDrop({super.key, required this.fill, required this.drop, required this.radius, required this.child, this.onTap, this.border});

  final Color fill;
  final Color drop;
  final double radius;
  final Widget child;
  final VoidCallback? onTap;
  final BoxBorder? border;

  @override
  State<HardDrop> createState() => _HardDropState();
}

class _HardDropState extends State<HardDrop> {
  bool _down = false; // press feedback only, not app data

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final pressed = _down && enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.fill,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border,
          boxShadow: [BoxShadow(color: widget.drop, offset: Offset(0, pressed ? 1 : 3))],
        ),
        child: widget.child,
      ),
    );
  }
}
