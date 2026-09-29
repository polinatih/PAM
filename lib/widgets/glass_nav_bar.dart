import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Плавающее нижнее меню: стандартный NavigationBar (Material 3),
/// оформленный под стекло — прозрачный фон внутри GlassCard,
/// тёмный индикатор у выбранного пункта.
class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final clear = scheme.surface.withValues(alpha: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GlassCard(
        radius: 34,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 72,
            backgroundColor: clear,
            surfaceTintColor: clear,
            elevation: 0,
            indicatorColor: scheme.inverseSurface,
            indicatorShape: const StadiumBorder(),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                size: 22,
                color: states.contains(WidgetState.selected)
                    ? scheme.onInverseSurface
                    : scheme.onSurface,
              ),
            ),
            labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
          ),
          // Отступ снизу даёт внешний SafeArea, внутри меню он не нужен
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }
}
