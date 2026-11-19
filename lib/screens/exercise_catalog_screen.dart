import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/exercise.dart';
import '../models/exercises_model.dart';
import '../widgets/error_view.dart';
import '../widgets/exercise_card.dart';
import '../widgets/filter_pill.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/section_label.dart';

/// Каталог упражнений: поиск + фильтр по группе мышц + подгрузка ломтями.
/// Данные — из ExercisesModel (watch), три состояния на виду.
/// L5: поиск и фильтр выполняются НА СЕРВЕРЕ (load(search:, muscleGroup:)),
/// хвост списка просит следующую страницу (loadMore).
class ExerciseCatalogScreen extends StatefulWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  State<ExerciseCatalogScreen> createState() => _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends State<ExerciseCatalogScreen> {
  final _searchCtrl = TextEditingController(); // текст поля — эфемерный

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final model = context.watch<ExercisesModel>(); // watch в build (C7)

    // Три состояния: грузится / ошибка с retry / данные
    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<ExercisesModel>().load(), // read: действие
      );
    } else {
      final items = model.exercises;
      body = items.isEmpty
          ? Center(child: Text('Ничего не найдено', style: text.bodyLarge))
          : ListView.separated(
              // снизу запас под плавающее нижнее меню
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              // +1 — «хвост», который просит следующую страницу
              itemCount: items.length + (model.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == items.length) {
                  // read: действие (loadMore сам не извещает во время build)
                  context.read<ExercisesModel>().loadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return ExerciseCard(
                  exercise: items[i],
                  // push: «зайду и вернусь»; в адресе путешествует только id
                  onTap: () => context.push('/exercises/${items[i].id}'),
                );
              },
            );
    }

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
                          SectionLabel(model.all.isEmpty
                              ? 'Каталог · загрузка…'
                              : 'Каталог · ${model.all.length} упражнений'),
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

              // Поиск по названию
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(
                  controller: _searchCtrl,
                  // поиск на сервере — по «Enter» на клавиатуре
                  onSubmitted: (query) => context
                      .read<ExercisesModel>()
                      .load(search: query.trim()),
                ),
              ),
              const SizedBox(height: 14),

              // Фильтр по группе мышц: «Все» + группы из домена
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: muscleGroups.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final group = i == 0 ? '' : muscleGroups[i - 1];
                    return FilterPill(
                      label: i == 0 ? 'Все' : group,
                      selected: model.muscleGroup == group,
                      // фильтр на сервере: ?muscleGroup=
                      onTap: () => context
                          .read<ExercisesModel>()
                          .load(muscleGroup: group),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Стеклянное поле поиска.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _SearchField({required this.controller, required this.onSubmitted});

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
              controller: controller,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
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
