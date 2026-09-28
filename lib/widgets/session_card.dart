import 'package:flutter/material.dart';
import '../data/format.dart';
import '../data/mock_data.dart';

/// Карточка тренировочной сессии. Используется: дневник тренировок,
/// блок «последние сессии» на экране статистики.
class SessionCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback? onTap;

  const SessionCard({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final exercises = session.exerciseIds.map(exerciseById).toList();

    return Card(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(formatDate(session.date),
                        style: text.titleMedium),
                  ),
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text(formatDuration(session.durationMin)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in exercises)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e.name,
                        style: text.labelMedium
                            ?.copyWith(color: scheme.onSecondaryContainer),
                      ),
                    ),
                ],
              ),
              if (session.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  session.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
