import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.10),
            blurRadius: 40,
            spreadRadius: -18,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Material(
            color: scheme.surfaceContainerLowest.withValues(alpha: 0.58),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}