import 'package:flutter/material.dart';

/// Чип-«таблетка» для фильтров и выбора.
/// Используется: фильтр групп мышц в каталоге, выбор упражнений в форме сессии.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;

  /// true — выбранный чип акцентного цвета с галочкой (форма сессии);
  /// false — выбранный чип тёмный (фильтр каталога).
  final bool accent;
  final VoidCallback? onTap;

  const FilterPill({
    super.key,
    required this.label,
    this.selected = false,
    this.accent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final Color background;
    final Color foreground;
    if (selected && accent) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (selected) {
      background = scheme.inverseSurface;
      foreground = scheme.onInverseSurface;
    } else {
      background = scheme.surfaceContainerLowest.withValues(alpha: 0.6);
      foreground = scheme.onSurface;
    }

    return Material(
      color: background,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : BorderSide(color: scheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        customBorder: const StadiumBorder(),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (selected ? text.labelLarge : text.labelMedium)
                      ?.copyWith(color: foreground),
                ),
              ),
              if (selected && accent) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_rounded, size: 16, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
