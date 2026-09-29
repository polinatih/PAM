import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/exercise_card.dart';
import '../widgets/filter_pill.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/section_label.dart';

/// Каталог упражнений: поиск + фильтр по группе мышц.
/// На L2 поиск и фильтр только визуальные — заработают на L4
/// (на L5 — через GET /exercises?search=&muscleGroup=).
class ExerciseCatalogScreen extends StatelessWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок + кнопка «добавить» (POST /exercises)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                              'Каталог · ${mockExercises.length} упражнений'),
                          const SizedBox(height: 6),
                          Text('Упражнения', style: text.headlineLarge),
                        ],
                      ),
                    ),
                    const GlassIconButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Добавить упражнение',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Поиск
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(),
              ),
              const SizedBox(height: 14),

              // Фильтр по группе мышц: «Все» + группы из данных
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: muscleGroups.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) => FilterPill(
                    label: i == 0 ? 'Все' : muscleGroups[i - 1],
                    selected: i == 0,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Список упражнений
              Expanded(
                child: ListView.separated(
                  // снизу запас под плавающее нижнее меню
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: mockExercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) => ExerciseCard(
                    exercise: mockExercises[i],
                    onTap: () {}, // переход на карточку — следующий шаг
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Стеклянное поле поиска. Пока только визуальное.
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GlassCard(
      radius: 27,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: text.bodyLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Поиск упражнения',
                hintStyle:
                    text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
