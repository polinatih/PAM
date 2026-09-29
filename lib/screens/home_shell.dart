import 'package:flutter/material.dart';

import '../widgets/glass_background.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/section_label.dart';
import 'exercise_catalog_screen.dart';
import 'progress_stats_screen.dart';
import 'workout_diary_screen.dart';

/// Временная навигация L2 (вариант 2 из задания): NavigationBar на 4 пункта.
/// Единственный StatefulWidget — хранит только индекс выбранной вкладки;
/// сами экраны остаются StatelessWidget. На L3 заменится на go_router.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = <Widget>[
    ExerciseCatalogScreen(),
    WorkoutDiaryScreen(),
    ProgressStatsScreen(),
    _ComingSoon(title: 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Контент уходит под плавающее меню — видно стекло
      extendBody: true,
      body: _screens[_index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: GlassNavBar(
          selectedIndex: _index,
          onSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Каталог',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Дневник',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Статистика',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}

/// Временная заглушка для вкладок, которые ещё не свёрстаны.
class _ComingSoon extends StatelessWidget {
  final String title;

  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: Center(child: SectionLabel('$title · в работе')),
      ),
    );
  }
}
