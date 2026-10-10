import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'glass_nav_bar.dart';

/// Обёртка с постоянными вкладками (StatefulShellRoute).
/// StatelessWidget: текущий индекс знает router (navigationShell),
/// поэтому StatefulWidget-обёртка из L2 (HomeShell) больше не нужна.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
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
