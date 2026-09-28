import 'package:flutter/material.dart';
import '../data/format.dart';
import '../data/mock_data.dart';
import '../widgets/session_card.dart';
import '../widgets/stat_tile.dart';

/// Статистика прогресса: сессии в неделю, суммарная длительность.
class ProgressStatsScreen extends StatelessWidget {
  const ProgressStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final totalMin = mockSessions.fold<int>(0, (s, e) => s + e.durationMin);
    final avgMin = totalMin ~/ mockSessions.length;
    final maxSessions =
        mockWeeks.map((w) => w.sessions).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.event_available,
                  value: '${mockSessions.length}',
                  label: 'Сессий в сентябре',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  value: formatDuration(totalMin),
                  label: 'Суммарно',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.av_timer,
                  value: '$avgMin мин',
                  label: 'Средняя сессия',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: StatTile(
                  icon: Icons.local_fire_department_outlined,
                  value: '3 нед.',
                  label: 'Серия без пропусков',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Сессии в неделю', style: text.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final w in mockWeeks)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${w.sessions}', style: text.labelLarge),
                                const SizedBox(height: 4),
                                Container(
                                  width: 36,
                                  height: 100 * w.sessions / maxSessions,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  w.label,
                                  style: text.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                for (final w in mockWeeks)
                  ListTile(
                    dense: true,
                    title: Text(w.label),
                    subtitle: LinearProgressIndicator(
                      value: (w.sessions / mockUser.weeklyGoal)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    trailing: Text(formatDuration(w.minutes)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Последние сессии', style: text.titleMedium),
          const SizedBox(height: 8),
          for (final s in mockSessions.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SessionCard(session: s),
            ),
        ],
      ),
    );
  }
}
