import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/exercises_model.dart';
import '../models/sessions_model.dart';
import '../models/user_model.dart';
import '../widgets/arc_ring.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_tile.dart';

/// Профиль пользователя. Бэкенд (GET /me) знает о пользователе только
/// id, email и name — поэтому показываем имя, e-mail и счётчики,
/// посчитанные из сессий и упражнений.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // watch в build: профиль показывает пользователя и следит за ним
    final user = context.watch<UserModel>().user;
    final name = user?.name ?? 'Гость';
    final email = user?.email ?? '';

    // Инициалы для аватара: «Ана Русу» → «АР»
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join();
    // Счётчики — из моделей (watch): после добавления/удаления сессии
    // профиль обновится сам. Пока данные грузятся — «…».
    final diary = context.watch<SessionsModel>();
    final catalog = context.watch<ExercisesModel>();
    final sessionsCount =
        diary.isLoading ? '…' : '${diary.sessions.length}';
    final hours = diary.isLoading ? '…' : '${diary.totalMinutes ~/ 60}';
    final exercisesCount =
        catalog.isLoading ? '…' : '${catalog.all.length}';

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
                name,
                textAlign: TextAlign.center,
                style: text.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                email,
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
                      value: sessionsCount,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'В зале',
                      value: hours,
                      unit: 'ч',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Упражн.',
                      value: exercisesCount,
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
                      count: catalog.all.length,
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
                      count: diary.sessions.length,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Выход — деструктивное действие: сначала диалог подтверждения
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
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

/// Диалог «Выйти из аккаунта?»: блокирующее решение → AlertDialog с результатом.
Future<void> _logout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Выйти из аккаунта?'),
      content: const Text('Чтобы снова открыть дневник, нужно будет войти.'),
      actions: [
        TextButton(
          // dialogCtx: под вложенными навигаторами вкладок
          // pop по context экрана закрыл бы не диалог
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Нет'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text('Да, выйти'),
        ),
      ],
    ),
  );
  // ok == true: закрытый мимо диалог возвращает null.
  // После await context используем только если он ещё mounted.
  if (ok == true && context.mounted) {
    context.read<UserModel>().signOut(); // read: это действие, а не показ
    context.go('/login'); // go: раздел с вкладками уходит из стека
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
