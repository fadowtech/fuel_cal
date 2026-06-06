import 'dart:math' as math;
import 'package:flutter/material.dart';

class OdometerGaugePainter extends CustomPainter {
  final double percentage; // 0.0 to 1.0
  final Color trackColor;
  final List<Color> gradientColors;
  final double strokeWidth;

  OdometerGaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.gradientColors,
    this.strokeWidth = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - (strokeWidth / 2);

    final startAngle = 180 * math.pi / 180;
    final sweepAngle = 180 * math.pi / 180;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Foreground progress
    if (percentage > 0) {
      final progressSweepAngle = sweepAngle * percentage;
      
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: gradientColors,
        tileMode: TileMode.clamp,
        transform: GradientRotation(startAngle - math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressSweepAngle,
        false,
        progressPaint,
      );

      // Draw dot at the end
      final currentAngle = startAngle + progressSweepAngle;
      final dotX = center.dx + radius * math.cos(currentAngle);
      final dotY = center.dy + radius * math.sin(currentAngle);

      final dotPaint = Paint()
        ..color = const Color(0xFF00FF9D) // explicit bright green dot
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 0.7, dotPaint);
    } else {
      // Draw dot at start if 0
      final dotX = center.dx + radius * math.cos(startAngle);
      final dotY = center.dy + radius * math.sin(startAngle);
      final dotPaint = Paint()
        ..color = const Color(0xFF00FF9D) // explicit bright green dot
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 0.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OdometerGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.gradientColors != gradientColors ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
