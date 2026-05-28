import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WindingPathPainter extends CustomPainter {
  final int levelCount;
  final List<Alignment> alignments;
  final double itemHeight;

  WindingPathPainter({
    required this.levelCount,
    required this.alignments,
    required this.itemHeight,
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

    // Need to connect the centers of each item
    for (int i = 0; i < levelCount - 1; i++) {
      final currentAlign = alignments[i % alignments.length];
      final nextAlign = alignments[(i + 1) % alignments.length];

      // Calculate center coordinates
      // Since it's RTL, Alignment.centerRight is visually on the right
      // itemHeight is the approximate height of each item in the list
      double startX = size.width / 2 + (currentAlign.x * size.width / 3);
      double startY = (i * itemHeight) + (itemHeight / 2) - 20; // -20 offset for bubble vs text

      double endX = size.width / 2 + (nextAlign.x * size.width / 3);
      double endY = ((i + 1) * itemHeight) + (itemHeight / 2) - 20;

      if (i == 0) {
        path.moveTo(startX, startY);
      }

      // Draw a bezier curve for smooth winding
      double controlPointY = startY + (endY - startY) / 2;
      path.cubicTo(
        startX, controlPointY, 
        endX, controlPointY, 
        endX, endY
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Static path
  }
}
