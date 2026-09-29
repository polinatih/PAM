import 'package:flutter/material.dart';

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

    return Material(
      color: scheme.inverseSurface,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 26),
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
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}