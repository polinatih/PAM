import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Круглая стеклянная кнопка с иконкой: «назад», «добавить», «редактировать».
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 48,
        height: 48,
        child: GlassCard(
          radius: 24,
          padding: EdgeInsets.zero,
          onTap: onPressed ?? () {},
          child: Center(child: Icon(icon, size: 20, color: scheme.onSurface)),
        ),
      ),
    );
  }
}