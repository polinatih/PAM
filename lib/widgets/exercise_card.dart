import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'exercise_thumb.dart';
import 'glass_card.dart';
import 'section_label.dart';

/// Карточка упражнения в списке. Используется: каталог, форма сессии
/// (выбранные упражнения — там вместо стрелки кнопка «убрать»).
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  /// Виджет справа. По умолчанию — стрелка «>».
  final Widget? trailing;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(11, 11, 16, 11),
      onTap: onTap,
      child: Row(
        children: [
          ExerciseThumb(muscleGroup: exercise.muscleGroup),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 4),
                SectionLabel(exercise.muscleGroup),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
