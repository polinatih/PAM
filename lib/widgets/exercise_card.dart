import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'muscle_avatar.dart';

/// Карточка упражнения. Используется: каталог, «похожие упражнения»
/// на экране упражнения, список выбранных упражнений в форме сессии.
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
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
    return Card(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: MuscleAvatar(muscleGroup: exercise.muscleGroup),
        title: Text(
          exercise.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${exercise.muscleGroup} · ${exercise.equipment}'),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
