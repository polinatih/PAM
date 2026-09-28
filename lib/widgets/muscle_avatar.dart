import 'package:flutter/material.dart';

/// Иконка-заглушка вместо изображения упражнения: иконка по группе мышц.
/// Используется в ExerciseCard, на экране упражнения и в форме сессии.
class MuscleAvatar extends StatelessWidget {
  final String muscleGroup;
  final double size;

  const MuscleAvatar({super.key, required this.muscleGroup, this.size = 44});

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
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        iconFor(muscleGroup),
        size: size * 0.55,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
