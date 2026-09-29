import 'package:flutter/material.dart';

/// «Войти», «Сохранить сессию», «Добавить в сессию».
class PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 60,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.inverseSurface,
          foregroundColor: scheme.onInverseSurface,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.only(left: 26, right: 8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: text.titleLarge?.copyWith(color: scheme.onInverseSurface),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: scheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}