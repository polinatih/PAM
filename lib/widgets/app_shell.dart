import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/sessions_model.dart';

import 'glass_nav_bar.dart';

/// Обёртка с постоянными вкладками (StatefulShellRoute).
/// StatelessWidget: текущий индекс знает router (navigationShell),
/// поэтому StatefulWidget-обёртка из L2 (HomeShell) больше не нужна.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Один «живой угол» — Consumer: перерисовывается только бейдж,
    // а не весь shell. Число сессий меняется из формы и из дневника.
    Widget diaryIcon(IconData icon) => Consumer<SessionsModel>(
          builder: (context, diary, child) => Badge(
            isLabelVisible: !diary.isLoading && diary.sessions.isNotEmpty,
            backgroundColor: scheme.primary,
            textColor: scheme.onPrimary,
            label: Text('${diary.sessions.length}'),
            child: child,
          ),
          child: Icon(icon),
        );

    return Scaffold(
      // Контент уходит под плавающее меню — видно стекло
      extendBody: true,
      body: navigationShell, // содержимое текущей вкладки
      bottomNavigationBar: SafeArea(
        top: false,
        child: GlassNavBar(
          selectedIndex: navigationShell.currentIndex,
          // Повторное нажатие на текущую вкладку возвращает к её началу
          onSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Каталог',
            ),
            NavigationDestination(
              icon: diaryIcon(Icons.menu_book_outlined),
              selectedIcon: diaryIcon(Icons.menu_book),
              label: 'Дневник',
            ),
            const NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Статистика',
            ),
            const NavigationDestination(
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
