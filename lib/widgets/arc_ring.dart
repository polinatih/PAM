import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcRing extends StatelessWidget {
  final double size;
  final Widget child;

  const ArcRing({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcRingPainter(ink: scheme.onSurface, accent: scheme.primary),
        child: Center(child: child),
      ),
    );
  }
}

class _ArcRingPainter extends CustomPainter {
  final Color ink;
  final Color accent;

  _ArcRingPainter({required this.ink, required this.accent});

  static const _start = 143.0 * math.pi / 180;
  static const _sweep = 254.0 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ink.withValues(alpha: 0.08),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = ink,
    );

    final end = _start + _sweep;
    canvas.drawCircle(
      center + Offset(math.cos(end), math.sin(end)) * radius,
      6,
      Paint()..color = accent,
    );

    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.3);
    final inner = Rect.fromCircle(center: center, radius: radius * 0.75);
    for (var a = 0.0; a < 2 * math.pi; a += 0.08) {
      canvas.drawArc(inner, a, 0.02, false, dash);
    }
  }

  @override
  bool shouldRepaint(_ArcRingPainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.accent != accent;
}