import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/arc_ring.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_tile.dart';
import 'login_screen.dart';

/// Профиль пользователя. Бэкенд (GET /me) знает о пользователе только
/// id, email и name — поэтому показываем имя, e-mail и счётчики,
/// посчитанные из сессий и упражнений.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Инициалы для аватара: «Ана Русу» → «АР»
    final initials = mockUser.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join();
    final totalMin =
        mockSessions.fold<int>(0, (sum, s) => sum + s.durationMin);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              const Center(child: SectionLabel('Профиль')),
              const SizedBox(height: 16),

              // Аватар с инициалами внутри кольца
              Center(
                child: ArcRing(
                  size: 200,
                  child: SizedBox(
                    width: 136,
                    height: 136,
                    child: GlassCard(
                      radius: 68,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Text(
                          initials,
                          style: text.displayMedium?.copyWith(fontSize: 46),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Имя и e-mail — ровно поля из GET /me
              Text(
                mockUser.name,
                textAlign: TextAlign.center,
                style: text.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                mockUser.email,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Счётчики
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Сессий',
                      value: '${mockSessions.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'В зале',
                      value: '${totalMin ~/ 60}',
                      unit: 'ч',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Упражн.',
                      value: '${mockExercises.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Разделы
              GlassCard(
                radius: 28,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.fitness_center,
                      title: 'Мои упражнения',
                      count: mockExercises.length,
                    ),
                    Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: scheme.onSurface.withValues(alpha: 0.06),
                    ),
                    _MenuRow(
                      icon: Icons.menu_book_outlined,
                      title: 'Все тренировки',
                      count: mockSessions.length,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Выход: возвращает на экран входа и очищает историю переходов
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    shape: const StadiumBorder(),
                    side: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.18)),
                    textStyle: text.labelLarge,
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Строка раздела: иконка, название, количество, стрелка.
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _MenuRow({required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: text.titleMedium)),
            SectionLabel('$count'),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
