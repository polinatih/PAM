import 'package:flutter/material.dart';

/// Миниатюра упражнения: иконка группы мышц в скруглённом квадрате.
/// На L2 заменяет фото (imageUrl). Используется в ExerciseCard.
class ExerciseThumb extends StatelessWidget {
  final String muscleGroup;
  final double size;

  const ExerciseThumb({super.key, required this.muscleGroup, this.size = 54});

  /// Иконка для каждой группы мышц.
  static IconData iconFor(String group) {
    switch (group) {
      case 'Грудь':
        return Icons.fitness_center;
      case 'Спина':
        return Icons.accessibility_new;
      case 'Ноги':
        return Icons.directions_walk;
      case 'Плечи':
        return Icons.sports_gymnastics;
      case 'Руки':
        return Icons.sports_martial_arts;
      case 'Пресс':
        return Icons.self_improvement;
      case 'Кардио':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(
          color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
        ),
      ),
      child: Icon(iconFor(muscleGroup), size: size * 0.44, color: scheme.primary),
    );
  }
}
