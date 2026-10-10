import 'package:go_router/go_router.dart';

import 'screens/exercise_catalog_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_stats_screen.dart';
import 'screens/session_form_screen.dart';
import 'screens/workout_diary_screen.dart';

/// Карта маршрутов приложения: у каждого экрана из ТЗ — свой адрес.
/// Адреса повторяют REST API бэкенда: /exercises/:id ↔ GET /exercises/{id}.
/// Router — глобальный объект: после изменения карты нужен restart (R).
final router = GoRouter(
  initialLocation: '/login', // приложение стартует со входа
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Каталог упражнений и карточка упражнения
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExerciseCatalogScreen(),
    ),
    GoRoute(
      path: '/exercises/:id', // /exercises/3 — упражнение №3
      builder: (context, state) {
        // Параметр пути — всегда String, перевод в int — наша задача
        final id = int.parse(state.pathParameters['id']!);
        return ExerciseDetailScreen(id: id);
      },
    ),

    // Дневник и форма сессии.
    // ФИКСИРОВАННЫЙ '/diary/new' стоит ПЕРЕД переменным '/diary/:id' —
    // маршруты проверяются сверху вниз, иначе int.parse('new') упадёт.
    GoRoute(
      path: '/diary',
      builder: (context, state) => const WorkoutDiaryScreen(),
    ),
    GoRoute(
      path: '/diary/new', // новая сессия
      builder: (context, state) => const SessionFormScreen(),
    ),
    GoRoute(
      path: '/diary/:id', // редактирование сессии №id
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return SessionFormScreen(sessionId: id);
      },
    ),

    GoRoute(
      path: '/stats',
      builder: (context, state) => const ProgressStatsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
