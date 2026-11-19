import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/http_exercise_repository.dart';
import 'data/http_session_repository.dart';
import 'data/result.dart';
import 'data/token_store.dart';
import 'models/exercises_model.dart';
import 'models/sessions_model.dart';
import 'models/user_model.dart';
import 'router.dart';

/// Адрес бэкенда. Эмулятор Android не знает «localhost» ноутбука:
/// сервер на ноутбуке для эмулятора — 10.0.2.2. На телефоне — IP ноутбука.
const apiBase = 'http://10.0.2.2:8080';

/// Корень композиции: ЗДЕСЬ (и только здесь) выбирается источник данных.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prefs до runApp (C9)
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null; // запуск решает по token-у

  router = GoRouter(
    initialLocation: loggedIn ? '/exercises' : '/login',
    routes: appRoutes, // карта L3 — без изменений
  );

  final auth = AuthApi(apiBase, tokens);

  // ЕДИНСТВЕННОЕ изменение источника данных: mock → http.
  // 401 в любом репозитории → назад на login, решено в одном месте.
  void toLogin() => router.go('/login');
  final exerciseRepository =
      HttpExerciseRepository(apiBase, tokens, onUnauthorized: toLogin);
  final sessionRepository =
      HttpSessionRepository(apiBase, tokens, onUnauthorized: toLogin);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>.value(value: auth),
        ChangeNotifierProvider(
          create: (_) => ExercisesModel(exerciseRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionsModel(sessionRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final user = UserModel();
            // token есть → узнаём, чей он (GET /me), для профиля
            if (loggedIn) {
              auth.me().then((result) {
                if (result case Ok(:final value)) user.signIn(value);
              });
            }
            return user;
          },
        ),
      ],
      child: const MyApp(), // MaterialApp.router — нетронут с L3
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E45F5),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    // MaterialApp.router: навигацию принимает router, параметра home: больше нет
    return MaterialApp.router(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surfaceContainer,
        textTheme: _buildTextTheme(scheme),
      ),
      routerConfig: router,
    );
  }

  TextTheme _buildTextTheme(ColorScheme scheme) {
    final ink = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;

    return TextTheme(
      displayLarge: GoogleFonts.lineSeedJp(
          fontSize: 64, fontWeight: FontWeight.w100, height: 1,
          letterSpacing: -2, color: ink),
      displayMedium: GoogleFonts.lineSeedJp(
          fontSize: 52, fontWeight: FontWeight.w100, height: 1,
          letterSpacing: -1.5, color: ink),
      displaySmall: GoogleFonts.lineSeedJp(
          fontSize: 34, fontWeight: FontWeight.w100, height: 1, color: ink),

      headlineLarge: GoogleFonts.lineSeedJp(
          fontSize: 40, fontWeight: FontWeight.w400, height: 1,
          letterSpacing: -0.8, color: ink),
      headlineMedium: GoogleFonts.lineSeedJp(
          fontSize: 34, fontWeight: FontWeight.w400, height: 1.1,
          letterSpacing: -0.7, color: ink),

      titleLarge: GoogleFonts.lineSeedJp(
          fontSize: 17, fontWeight: FontWeight.w700, color: ink),
      titleMedium: GoogleFonts.lineSeedJp(
          fontSize: 16, fontWeight: FontWeight.w400, color: ink),


      bodyLarge: GoogleFonts.lineSeedJp(
          fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: ink),
      bodyMedium: GoogleFonts.lineSeedJp(
          fontSize: 15, fontWeight: FontWeight.w400, height: 1.45, color: ink),
      bodySmall: GoogleFonts.lineSeedJp(
          fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: muted),

      labelLarge: GoogleFonts.lineSeedJp(
          fontSize: 14, fontWeight: FontWeight.w700, color: ink),
      labelMedium: GoogleFonts.lineSeedJp(
          fontSize: 14, fontWeight: FontWeight.w400, color: ink),

      labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 1.1,
          color: muted),
    );
  }
}