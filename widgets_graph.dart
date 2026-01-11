import 'package:flutter/material.dart';
import 'dart:math' as math;

class HistoryGraph extends CustomPainter {
  final List<double> history;
  final Animation<double> animation;

  HistoryGraph({
    required this.history,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final linePaint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [Colors.greenAccent, Colors.blueAccent],
      ).createShader(Offset.zero & size);

    final maxVal = history.reduce(math.max);
    final minVal = history.reduce(math.min);

    final range = (maxVal - minVal).abs();
    final safeRange = range == 0 ? 1.0 : range;

    double mapY(double v) {
      final normalized = (v - minVal) / safeRange;
      // animation.value من 0 -> 1 فبيطلع الخط تدريجيًا
      return size.height - normalized * size.height * animation.value;
    }

    // لو نقطة واحدة: ارسم دائرة في النص
    if (history.length == 1) {
      final y = mapY(history.first);
      final x = size.width / 2;
      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.greenAccent;

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      return;
    }

    final stepX = size.width / (history.length - 1);

    // حضّر نقاط الرسم
    final points = <Offset>[
      for (var i = 0; i < history.length; i++)
        Offset(i * stepX, mapY(history[i])),
    ];

    // رسم منحنى ناعم (Quadratic Bezier)
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }

    // آخر وصلة
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant HistoryGraph oldDelegate) {
    // animation بيعمل repaint لوحده، وده يخلي الكود clean
    // لكن بنرجع true لو المرجع اتغيّر
    return oldDelegate.history != history || oldDelegate.animation != animation;
  }
}