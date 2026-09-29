import 'package:flutter/material.dart';

import '../data/format.dart';
import '../data/mock_data.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_label.dart';
import '../widgets/session_card.dart';
import 'session_form_screen.dart';

/// Дневник тренировок: сессии в хронологическом порядке (новые сверху),
/// как их отдаёт GET /workout-sessions.
class WorkoutDiaryScreen extends StatelessWidget {
  const WorkoutDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final latest = mockSessions.first.date;
    final totalMin =
        mockSessions.fold<int>(0, (sum, s) => sum + s.durationMin);

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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SessionFormScreen(),
                            ),
                          ),
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
                      _Summary(value: '${mockSessions.length}', label: 'сессий'),
                      Container(
                        width: 1,
                        height: 28,
                        color: scheme.onSurface.withValues(alpha: 0.1),
                      ),
                      _Summary(value: formatDuration(totalMin), label: 'всего'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Лента сессий
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: mockSessions.length,
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
                  itemBuilder: (context, i) =>
                      _TimelineItem(session: mockSessions[i]),
                ),
              ),
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
class _TimelineItem extends StatelessWidget {
  final WorkoutSession session;

  const _TimelineItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // IntrinsicHeight — чтобы линия слева была высотой с карточку
    return IntrinsicHeight(
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionFormScreen(session: session),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
