import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'section_label.dart';

/// Плитка-показатель: подпись сверху, крупное тонкое значение снизу.
/// Используется: статистика, профиль.
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  /// Единица рядом со значением: «мин», «ч».
  final String? unit;

  /// Акцентная строка под значением: «3 раза».
  final String? caption;

  /// true — значение крупными тонкими цифрами; false — текстом (название).
  final bool numeric;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.caption,
    this.numeric = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(label),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: numeric
                            ? text.displaySmall?.copyWith(fontSize: 38)
                            : text.titleLarge,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        unit!,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  SectionLabel(caption!, color: scheme.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
