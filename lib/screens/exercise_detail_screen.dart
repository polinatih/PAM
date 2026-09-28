import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/exercise_card.dart';
import '../widgets/info_row.dart';
import '../widgets/muscle_avatar.dart';

/// Карточка упражнения: изображение (заглушка), описание, техника.
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final similar = mockExercises
        .where((e) =>
            e.muscleGroup == exercise.muscleGroup && e.id != exercise.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Упражнение'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // «Изображение»: цветной контейнер с крупной иконкой группы мышц
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                MuscleAvatar.iconFor(exercise.muscleGroup),
                size: 96,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(exercise.name, style: text.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(exercise.muscleGroup)),
              Chip(label: Text('Сложность: ${exercise.difficulty}')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Описание', style: text.titleMedium),
                  const SizedBox(height: 6),
                  Text(exercise.description, style: text.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Техника выполнения', style: text.titleMedium),
                  const SizedBox(height: 8),
                  for (var i = 0; i < exercise.technique.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: scheme.primary,
                            child: Text(
                              '${i + 1}',
                              style: text.labelSmall
                                  ?.copyWith(color: scheme.onPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(exercise.technique[i])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.handyman_outlined,
                  label: 'Инвентарь',
                  value: exercise.equipment,
                ),
                InfoRow(
                  icon: Icons.accessibility_new,
                  label: 'Группа мышц',
                  value: exercise.muscleGroup,
                ),
              ],
            ),
          ),
          if (similar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Похожие упражнения', style: text.titleMedium),
            const SizedBox(height: 8),
            for (final e in similar)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExerciseCard(exercise: e),
              ),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Добавить в тренировку'),
          ),
        ],
      ),
    );
  }
}
