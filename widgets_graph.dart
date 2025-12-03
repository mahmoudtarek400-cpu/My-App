import 'package:flutter/material.dart';
import 'dart:math' as math;

class HistoryGraph extends CustomPainter {
  final List<double> history;
  final Animation<double> animation;

  HistoryGraph({required this.history, required this.animation}) : super(repaint: animation);

  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [Colors.greenAccent, Colors.blueAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxVal = history.reduce(math.max);
    final minVal = history.reduce(math.min);
    final range = (maxVal - minVal).abs() == 0 ? 1 : (maxVal - minVal);

    final stepX = size.width / (history.length - 1);
    final path = Path();

    for (int i = 0; i < history.length; i++) {
      final x = i * stepX;
      final normalized = (history[i] - minVal) / range;
      final y = size.height - normalized * size.height * animation.value;

      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}