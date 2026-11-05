import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/format.dart';
import '../data/workout_session.dart';
import '../models/sessions_model.dart';
import '../widgets/error_view.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_label.dart';
import '../widgets/session_card.dart';

/// Дневник тренировок: сессии в хронологическом порядке (новые сверху),
/// как их отдаёт GET /workout-sessions. Данные — из SessionsModel (watch).
class WorkoutDiaryScreen extends StatelessWidget {
  const WorkoutDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final model = context.watch<SessionsModel>(); // watch в build (C7)
    final sessions = model.sessions;
    final latest = sessions.isEmpty ? DateTime.now() : sessions.first.date;

    // Три состояния: грузится / ошибка с retry / данные
    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<SessionsModel>().load(),
      );
    } else if (sessions.isEmpty) {
      body = Center(
        child: Text('Пока нет тренировок — добавьте первую',
            style: text.bodyLarge),
      );
    } else {
      body = RefreshIndicator(
        // потянуть вниз — перезагрузить (read: действие)
        onRefresh: () => context.read<SessionsModel>().load(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          itemCount: sessions.length,
          // Разделитель продолжает вертикальную линию ленты
          separatorBuilder: (context, index) => SizedBox(
            height: 14,
            child: Row(
              children: [
                const SizedBox(width: 31),
                Container(
                  width: 1,
                  color: scheme.onSurface.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),
          itemBuilder: (context, i) => _TimelineItem(session: sessions[i]),
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
              // Заголовок + акцентная кнопка «новая сессия»
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
                            'Дневник · ${monthName(latest).toLowerCase()} '
                            '${latest.year}',
                          ),
                          const SizedBox(height: 6),
                          Text('Тренировки', style: text.headlineLarge),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Новая сессия',
                      child: Material(
                        color: scheme.primary,
                        shape: const CircleBorder(),
                        elevation: 6,
                        shadowColor: scheme.primary.withValues(alpha: 0.6),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.push('/diary/new'),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(Icons.add_rounded,
                                color: scheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Итог: количество сессий и суммарное время
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  radius: 32,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Summary(
                        value: model.isLoading ? '…' : '${sessions.length}',
                        label: 'сессий',
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: scheme.onSurface.withValues(alpha: 0.1),
                      ),
                      _Summary(
                        value: model.isLoading
                            ? '…'
                            : formatDuration(model.totalMinutes),
                        label: 'всего',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Лента сессий — в одном из трёх состояний
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// «8 сессий», «8 ч 03 мин всего»
class _Summary extends StatelessWidget {
  final String value;
  final String label;

  const _Summary({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: text.displaySmall?.copyWith(fontSize: 24)),
        const SizedBox(width: 6),
        SectionLabel(label),
      ],
    );
  }
}

/// Один элемент ленты: слева день и день недели с линией, справа карточка.
/// Свайп влево — удаление (с диалогом подтверждения).
class _TimelineItem extends StatelessWidget {
  final WorkoutSession session;

  const _TimelineItem({required this.session});

  /// Диалог → удаление через модель → SnackBar.
  /// Возвращает false: строку убирает не Dismissible, а модель —
  /// после notifyListeners список перерисуется без этой сессии.
  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить тренировку?'),
        content: Text(
            'Сессию от ${formatDateShort(session.date)} нельзя будет восстановить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<SessionsModel>().remove(session.id);
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(error ?? 'Сессия удалена'),
    ));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Ключ — идентичность из данных (id), а не UniqueKey (C7)
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: scheme.onErrorContainer),
      ),
      // IntrinsicHeight — чтобы линия слева была высотой с карточку
      child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Text(
                  '${session.date.day}',
                  style: text.displaySmall?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 2),
                SectionLabel(weekdayShort(session.date)),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: 1,
                    color: scheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SessionCard(
              session: session,
              // Нажатие на сессию открывает форму в режиме редактирования
              onTap: () => context.push('/diary/${session.id}'),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
