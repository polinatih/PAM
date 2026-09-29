import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  final bool mirrored;

  const GlassBackground({
    super.key,
    required this.child,
    this.mirrored = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: scheme.surfaceContainer)),
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(scheme.onSurface.withValues(alpha: 0.08)),
          ),
        ),
        _Orb(
          size: 300,
          color: scheme.primary.withValues(alpha: 0.28),
          top: -80,
          left: mirrored ? -110 : null,
          right: mirrored ? null : -110,
        ),
        _Orb(
          size: 260,
          color: scheme.primaryContainer.withValues(alpha: 0.6),
          top: 460,
          left: mirrored ? null : -120,
          right: mirrored ? -120 : null,
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double top;
  final double? left;
  final double? right;

  const _Orb({
    required this.size,
    required this.color,
    required this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
              sigmaX: 60, sigmaY: 60, tileMode: TileMode.decal),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;

  _DotGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 14.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.color != color;
}