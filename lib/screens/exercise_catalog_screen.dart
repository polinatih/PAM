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

/// Каталог упражнений: поиск + фильтр по группе мышц.
/// Данные — из ExercisesModel (watch), три состояния на виду.
/// Выбранный фильтр и текст поиска — эфемерное состояние экрана → setState.
class ExerciseCatalogScreen extends StatefulWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  State<ExerciseCatalogScreen> createState() => _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends State<ExerciseCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String? _group; // null — «Все»

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Фильтр по группе и поиск по названию — поверх загруженного списка.
  List<Exercise> _filter(List<Exercise> all) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return all
        .where((e) => _group == null || e.muscleGroup == _group)
        .where((e) => query.isEmpty || e.name.toLowerCase().contains(query))
        .toList();
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
      final items = _filter(model.exercises);
      body = items.isEmpty
          ? Center(child: Text('Ничего не найдено', style: text.bodyLarge))
          : ListView.separated(
              // снизу запас под плавающее нижнее меню
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ExerciseCard(
                exercise: items[i],
                // push: «зайду и вернусь»; в адресе путешествует только id
                onTap: () => context.push('/exercises/${items[i].id}'),
              ),
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
                          SectionLabel(model.isLoading
                              ? 'Каталог · загрузка…'
                              : 'Каталог · ${model.exercises.length} упражнений'),
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
                  onChanged: (_) => setState(() {}),
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
                    final group = i == 0 ? null : muscleGroups[i - 1];
                    return FilterPill(
                      label: group ?? 'Все',
                      selected: _group == group,
                      onTap: () => setState(() => _group = group),
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
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

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
              onChanged: onChanged,
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
