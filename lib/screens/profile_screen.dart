import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/info_row.dart';
import '../widgets/stat_tile.dart';
import 'login_screen.dart';

/// Профиль пользователя.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final initials = mockUser.name.split(' ').map((p) => p[0]).take(2).join();
    final totalMin = mockSessions.fold<int>(0, (s, e) => s + e.durationMin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                initials,
                style: text.headlineMedium
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(mockUser.name,
              textAlign: TextAlign.center, style: text.titleLarge),
          Text(
            '${mockUser.email} · ${mockUser.group}',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.event_available,
                  value: '${mockSessions.length}',
                  label: 'Тренировок',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  value: '${totalMin ~/ 60} ч',
                  label: 'В зале',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.fitness_center,
                  value: '${mockExercises.length}',
                  label: 'Упражнений',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Цель',
                  value: '${mockUser.weeklyGoal} тренировки в неделю',
                ),
                InfoRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Вес',
                  value: '${mockUser.weightKg} кг',
                ),
                InfoRow(
                  icon: Icons.height,
                  label: 'Рост',
                  value: '${mockUser.heightCm} см',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Напоминания о тренировках'),
                  value: true,
                  onChanged: (_) {},
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Экспорт дневника в CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
