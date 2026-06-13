import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WindingPathPainter extends CustomPainter {
  final int levelCount;
  final List<Alignment> alignments;
  final double itemHeight;
  final double topPadding;

  WindingPathPainter({
    required this.levelCount,
    required this.alignments,
    required this.itemHeight,
    this.topPadding = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (levelCount <= 1) return;

    final paint = Paint()
      ..color = AppColors.beigeDark
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Connect the centers of each level bubble
    for (int i = 0; i < levelCount - 1; i++) {
      final currentAlign = alignments[i % alignments.length];
      final nextAlign = alignments[(i + 1) % alignments.length];

      // Calculate center coordinates within the total content area
      double startX = size.width / 2 + (currentAlign.x * size.width / 3);
      double startY = topPadding + (i * itemHeight) + (itemHeight / 2) - 20;

      double endX = size.width / 2 + (nextAlign.x * size.width / 3);
      double endY = topPadding + ((i + 1) * itemHeight) + (itemHeight / 2) - 20;

      if (i == 0) {
        path.moveTo(startX, startY);
      }

      // Draw a bezier curve for smooth winding
      double controlPointY = startY + (endY - startY) / 2;
      path.cubicTo(
        startX, controlPointY, 
        endX, controlPointY, 
        endX, endY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WindingPathPainter oldDelegate) {
    return oldDelegate.levelCount != levelCount ||
        oldDelegate.itemHeight != itemHeight ||
        oldDelegate.topPadding != topPadding;
  }
}
