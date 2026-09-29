import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/format.dart';
import '../data/mock_data.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_label.dart';
import '../widgets/session_card.dart';
import '../widgets/stat_tile.dart';

/// Статистика прогресса: сессии в неделю и суммарная длительность.
/// Отдельного endpoint-а для статистики нет — всё считается в приложении
/// из списка сессий (на L5 — из ответа GET /workout-sessions).
class ProgressStatsScreen extends StatelessWidget {
  const ProgressStatsScreen({super.key});

  /// Группируем сессии по неделям месяца: 1–7, 8–14, 15–21, 22–28.
  static List<_Week> _weeks() {
    const labels = ['1–7', '8–14', '15–21', '22–28'];
    final sessions = List.filled(4, 0);
    final minutes = List.filled(4, 0);
    for (final s in mockSessions) {
      final w = math.min((s.date.day - 1) ~/ 7, 3);
      sessions[w]++;
      minutes[w] += s.durationMin;
    }
    return [
      for (var i = 0; i < 4; i++) _Week(labels[i], sessions[i], minutes[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final weeks = _weeks();
    final current = weeks.last;
    final totalMin =
        mockSessions.fold<int>(0, (sum, s) => sum + s.durationMin);
    final avgMin = totalMin ~/ mockSessions.length;

    // Самое частое упражнение: считаем, сколько раз встречается каждый id
    final counts = <int, int>{};
    for (final s in mockSessions) {
      for (final id in s.exerciseIds) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a);

    final latest = mockSessions.first.date;

    return Scaffold(
      body: GlassBackground(
        mirrored: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      'Прогресс · ${monthName(latest).toLowerCase()} '
                      '${latest.year}',
                    ),
                    const SizedBox(height: 6),
                    Text('Статистика', style: text.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Суммарная длительность + линия минут по неделям
              GlassCard(
                radius: 32,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Суммарная длительность'),
                    const SizedBox(height: 8),
                    Text(formatDuration(totalMin), style: text.displayMedium),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LineChartPainter(
                                values: [for (final w in weeks) w.minutes],
                                line: scheme.primary,
                                dot: scheme.onSurface,
                                highlight: scheme.primary.withValues(alpha: 0.1),
                                fill: scheme.surfaceContainerLowest,
                              ),
                            ),
                          ),
                          // Подсказка над текущей неделей
                          Positioned(
                            right: 56,
                            top: 0,
                            child: GlassCard(
                              radius: 14,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionLabel('${current.label} сент'),
                                  const SizedBox(height: 2),
                                  Text(formatDuration(current.minutes),
                                      style: text.labelLarge),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final w in weeks)
                          SectionLabel(
                            w.label,
                            color: w == current ? scheme.primary : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Сессии в неделю — столбики
              GlassCard(
                radius: 32,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: SectionLabel('Сессии в неделю')),
                        SectionLabel('всего ${mockSessions.length}',
                            color: scheme.onSurface),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: _WeekBars(weeks: weeks),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Плитки: средняя сессия и самое частое упражнение
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Средняя сессия',
                      value: '$avgMin',
                      unit: 'мин',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Чаще всего',
                      value: exerciseById(top.key).name,
                      caption: '${top.value} раза',
                      numeric: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Последняя тренировка
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SectionLabel('Последняя тренировка'),
              ),
              const SizedBox(height: 10),
              SessionCard(session: mockSessions.first, showFullDate: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Итог одной недели.
class _Week {
  final String label;
  final int sessions;
  final int minutes;

  const _Week(this.label, this.sessions, this.minutes);
}

/// Столбики «сессии в неделю»: обычные недели — штриховка,
/// лучшая — тёмная, текущая — акцентная.
class _WeekBars extends StatelessWidget {
  final List<_Week> weeks;

  const _WeekBars({required this.weeks});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxSessions = weeks.map((w) => w.sessions).reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < weeks.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Builder(builder: (context) {
                final w = weeks[i];
                final isCurrent = i == weeks.length - 1;
                final isBest = w.sessions == maxSessions;
                final barHeight = 120.0 * w.sessions / maxSessions;

                final Widget bar;
                if (isCurrent) {
                  bar = _solidBar(scheme.primary, barHeight);
                } else if (isBest) {
                  bar = _solidBar(scheme.inverseSurface, barHeight);
                } else {
                  bar = ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: barHeight,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _HatchPainter(
                            scheme.primary.withValues(alpha: 0.25)),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.25)),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${w.sessions}',
                      style: text.displaySmall?.copyWith(
                        fontSize: 22,
                        color: isCurrent ? scheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    bar,
                    const SizedBox(height: 8),
                    SectionLabel(w.label,
                        color: isCurrent ? scheme.primary : null),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _solidBar(Color color, double height) => Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}

/// Косая штриховка для обычных столбиков.
class _HatchPainter extends CustomPainter {
  final Color color;

  _HatchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width; x += 7) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color;
}

/// Плавная линия минут по неделям; текущая неделя подсвечена колонкой.
class _LineChartPainter extends CustomPainter {
  final List<int> values;
  final Color line;
  final Color dot;
  final Color highlight;
  final Color fill;

  _LineChartPainter({
    required this.values,
    required this.line,
    required this.dot,
    required this.highlight,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padX = 22.0;
    final maxValue = values.reduce(math.max).toDouble();
    final step = (size.width - padX * 2) / (values.length - 1);

    Offset point(int i) => Offset(
          padX + step * i,
          size.height - 12 - values[i] / maxValue * (size.height - 44),
        );

    // Подсветка текущей (последней) недели
    final last = point(values.length - 1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(last.dx, size.height / 2),
            width: 48,
            height: size.height),
        const Radius.circular(14),
      ),
      Paint()..color = highlight,
    );

    // Плавная кривая через точки (кубические кривые Безье)
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p0 = point(i - 1);
      final p1 = point(i);
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = line,
    );

    // Точки прошлых недель
    for (var i = 0; i < values.length - 1; i++) {
      canvas.drawCircle(point(i), 3.5, Paint()..color = dot);
    }
    // Текущая неделя — кольцо
    canvas.drawCircle(last, 6, Paint()..color = fill);
    canvas.drawCircle(
      last,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.line != line;
}
