import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/login_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E45F5),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surfaceContainer,
        textTheme: _buildTextTheme(scheme),
      ),
      home: const LoginScreen(),
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