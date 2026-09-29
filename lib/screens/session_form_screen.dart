import 'package:flutter/material.dart';

import '../data/format.dart';
import '../data/mock_data.dart';
import '../widgets/filter_pill.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_label.dart';

/// Форма новой сессии / редактирования — макет без валидации и сохранения.
/// Поля = модель WorkoutSession: date, exerciseIds, durationMin, notes.
/// Если передан [session] — режим редактирования (PUT/DELETE на L5),
/// иначе — новая сессия (POST /workout-sessions на L5).
class SessionFormScreen extends StatelessWidget {
  final WorkoutSession? session;

  const SessionFormScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isEdit = session != null;
    final date = session?.date ?? DateTime(2026, 9, 29);
    final duration = session?.durationMin ?? 60;
    final selectedIds = session?.exerciseIds ?? const [1, 6];

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              // Верхняя панель: закрыть · режим · удалить
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.pop(context),
                  ),
                  SectionLabel(isEdit ? 'Редактирование' : 'Новая сессия'),
                  if (isEdit)
                    const GlassIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Удалить сессию',
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isEdit ? 'Изменить\nтренировку' : 'Запишите\nтренировку',
                  style: text.headlineMedium,
                ),
              ),
              const SizedBox(height: 22),

              // Дата
              GlassCard(
                radius: 26,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 20, color: scheme.primary),
                    const SizedBox(width: 14),
                    const SectionLabel('Дата'),
                    Expanded(
                      child: TextFormField(
                        initialValue: formatDateShort(date),
                        readOnly: true, // на L3 откроется выбор даты
                        textAlign: TextAlign.end,
                        style: text.bodyLarge,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Длительность
              GlassCard(
                radius: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Длительность'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const GlassIconButton(
                          icon: Icons.remove_rounded,
                          tooltip: 'Меньше',
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$duration', style: text.displayLarge),
                            const SizedBox(width: 8),
                            Text(
                              'мин',
                              style: text.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const GlassIconButton(
                          icon: Icons.add_rounded,
                          tooltip: 'Больше',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Упражнения: выбранные — акцентные чипы с галочкой
              GlassCard(
                radius: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: SectionLabel('Упражнения')),
                        SectionLabel(
                          'Выбрано · ${selectedIds.length}',
                          color: scheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in mockExercises)
                          FilterPill(
                            label: e.name,
                            selected: selectedIds.contains(e.id),
                            accent: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Заметки
              GlassCard(
                radius: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Заметки'),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: session?.notes ?? '',
                      minLines: 3,
                      maxLines: 5,
                      style: text.bodyLarge,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Веса, подходы, самочувствие…',
                        hintStyle: text.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                label: 'Сохранить сессию',
                icon: Icons.check_rounded,
                onPressed: () {}, // сохранение — L4/L5
              ),
            ],
          ),
        ),
      ),
    );
  }
}
