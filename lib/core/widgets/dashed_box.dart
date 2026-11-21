import 'package:flutter/widgets.dart';

/// A rounded box with a dashed edge: an empty answer slot or a used spot in the tray (DESIGN.md §5).
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.size, required this.fill, required this.edge, this.radius = 10});

  final double size;
  final Color fill;
  final Color edge;
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _DashedPainter(fill: fill, edge: edge, radius: radius)),
      );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.fill, required this.edge, required this.radius});

  final Color fill;
  final Color edge;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(rect, Paint()..color = fill);
    final path = Path()..addRRect(rect.deflate(stroke / 2));
    final paint = Paint()
      ..color = edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.fill != fill || old.edge != edge || old.radius != radius;
}
