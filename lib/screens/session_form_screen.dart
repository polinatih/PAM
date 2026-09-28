import 'package:flutter/material.dart';
import '../data/format.dart';
import '../data/mock_data.dart';
import '../widgets/exercise_card.dart';

/// Форма новой сессии / редактирования — макет без валидации и сохранения.
/// Если передан session — поля заполнены его данными (режим редактирования).
class SessionFormScreen extends StatelessWidget {
  final WorkoutSession? session;

  const SessionFormScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isEdit = session != null;
    final selectedIds = session?.exerciseIds ?? const ['e1', 'e7'];
    final selected = selectedIds.map(exerciseById).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактирование' : 'Новая сессия'),
        actions: [
          if (isEdit)
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: formatDateShort(session?.date ?? DateTime(2026, 9, 23)),
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Дата',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: '${session?.durationMin ?? 60}',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Длительность',
              suffixText: 'мин',
              prefixIcon: Icon(Icons.timer_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: 'Силовая',
            label: const Text('Тип тренировки'),
            leadingIcon: const Icon(Icons.category_outlined),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Силовая', label: 'Силовая'),
              DropdownMenuEntry(value: 'Кардио', label: 'Кардио'),
              DropdownMenuEntry(value: 'Смешанная', label: 'Смешанная'),
              DropdownMenuEntry(value: 'Растяжка', label: 'Растяжка'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Упражнения', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in mockExercises)
                FilterChip(
                  label: Text(e.name, overflow: TextOverflow.ellipsis),
                  selected: selectedIds.contains(e.id),
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Выбрано: ${selected.length}', style: text.titleSmall),
          const SizedBox(height: 8),
          for (final e in selected)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExerciseCard(
                exercise: e,
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: session?.notes ?? '',
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Заметки',
              hintText: 'Как прошла тренировка, веса, самочувствие…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Напомнить о следующей тренировке'),
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () {},
            icon: const Icon(Icons.save_outlined),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
