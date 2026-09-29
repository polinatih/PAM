import 'package:flutter/material.dart';

import '../data/format.dart';
import '../data/mock_data.dart';
import 'glass_card.dart';
import 'section_label.dart';

/// Карточка тренировочной сессии: длительность, упражнения, заметки.
/// Используется: дневник тренировок, статистика («последняя тренировка»).
class SessionCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback? onTap;

  /// true — в шапке полная дата «22.09.2026, вт» (статистика);
  /// false — только месяц, потому что день показан слева (дневник).
  final bool showFullDate;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.showFullDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // В сессии хранятся только id — названия берём из списка упражнений
    final exercises = session.exerciseIds.map(exerciseById).toList();

    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionLabel(
                  showFullDate
                      ? formatDateShort(session.date)
                      : monthName(session.date),
                  color: scheme.onSurface,
                ),
              ),
              Icon(Icons.schedule_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                formatDuration(session.durationMin),
                style: text.bodySmall?.copyWith(color: scheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in exercises)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    e.name,
                    style: text.bodySmall?.copyWith(color: scheme.onSurface),
                  ),
                ),
            ],
          ),
          if (session.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              session.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
