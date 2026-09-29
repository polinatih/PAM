import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/arc_ring.dart';
import '../widgets/exercise_thumb.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_label.dart';

/// Карточка упражнения: изображение, описание, техника выполнения.
/// Данные — один объект Exercise (на L5 — GET /exercises/{id}).
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final steps = exercise.techniqueSteps;

    return Scaffold(
      body: GlassBackground(
        mirrored: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              // Верхняя панель: назад · номер · редактировать
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Назад',
                    onPressed: () => Navigator.pop(context),
                  ),
                  SectionLabel('Упражнение · №${exercise.id}'),
                  const GlassIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Редактировать',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // «Изображение»: на L2 — кольцо с иконкой вместо фото (imageUrl)
              GlassCard(
                radius: 32,
                padding: EdgeInsets.zero,
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    children: [
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ArcRing(
                            size: 190,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  ExerciseThumb.iconFor(exercise.muscleGroup),
                                  size: 56,
                                  color: scheme.primary,
                                ),
                                const SizedBox(height: 8),
                                const SectionLabel('Фото · imageUrl'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Плашка с группой мышц поверх изображения
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: GlassCard(
                          radius: 18,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(exercise.muscleGroup,
                                  style: text.labelMedium),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Название
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                        'Группа мышц · ${exercise.muscleGroup.toLowerCase()}'),
                    const SizedBox(height: 8),
                    Text(exercise.name, style: text.headlineMedium),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Описание
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Описание'),
                    const SizedBox(height: 10),
                    Text(exercise.description, style: text.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Техника выполнения: нумерованные шаги
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Техника выполнения'),
                    const SizedBox(height: 14),
                    for (var i = 0; i < steps.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: i == steps.length - 1 ? 0 : 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: text.labelSmall?.copyWith(
                                    fontSize: 13, color: scheme.primary),
                              ),
                            ),
                            Expanded(
                              child: Text(steps[i], style: text.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                label: 'Добавить в сессию',
                icon: Icons.add_rounded,
                onPressed: () {}, // форма сессии — следующие шаги
              ),
            ],
          ),
        ),
      ),
    );
  }
}
