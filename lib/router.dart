import 'package:go_router/go_router.dart';

import 'screens/exercise_catalog_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_stats_screen.dart';
import 'screens/session_form_screen.dart';
import 'screens/workout_diary_screen.dart';
import 'widgets/app_shell.dart';

/// Карта маршрутов приложения: у каждого экрана из ТЗ — свой адрес.
/// Адреса повторяют REST API бэкенда: /exercises/:id ↔ GET /exercises/{id}.
/// Router — глобальный объект: после изменения карты нужен restart (R).
final router = GoRouter(
  initialLocation: '/login', // приложение стартует со входа
  routes: [
    // Вход — ВНЕ shell-а: на экране входа нет вкладок
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Постоянные вкладки: у каждой ветки свой стек и своё состояние
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Вкладка 1: каталог → карточка упражнения
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/exercises',
            builder: (context, state) => const ExerciseCatalogScreen(),
            routes: [
              GoRoute(
                path: ':id', // полный адрес: /exercises/3
                builder: (context, state) {
                  // Параметр пути — всегда String, перевод в int — наша задача
                  final id = int.parse(state.pathParameters['id']!);
                  return ExerciseDetailScreen(id: id);
                },
              ),
            ],
          ),
        ]),

        // Вкладка 2: дневник → форма сессии.
        // ФИКСИРОВАННЫЙ 'new' стоит ПЕРЕД переменным ':id' —
        // маршруты проверяются сверху вниз, иначе int.parse('new') упадёт.
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/diary',
            builder: (context, state) => const WorkoutDiaryScreen(),
            routes: [
              GoRoute(
                path: 'new', // полный адрес: /diary/new — новая сессия
                builder: (context, state) => const SessionFormScreen(),
              ),
              GoRoute(
                path: ':id', // полный адрес: /diary/8 — редактирование
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return SessionFormScreen(sessionId: id);
                },
              ),
            ],
          ),
        ]),

        // Вкладка 3: статистика
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const ProgressStatsScreen(),
          ),
        ]),

        // Вкладка 4: профиль
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ]),
      ],
    ),
  ],
);
