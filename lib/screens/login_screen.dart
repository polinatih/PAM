import 'package:flutter/material.dart';

import '../widgets/arc_ring.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_label.dart';
import 'home_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    children: [
                      const SectionLabel('FitTrack · дневник тренировок'),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ArcRing(
                              size: 300,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('FitTrack', style: text.displayMedium),
                                  const SizedBox(height: 8),
                                  Text(
                                                                      'Спокойный прогресс.\nКаждый день.',
                                                                      textAlign: TextAlign.center,
                                                                      style: text.bodyMedium?.copyWith(
                                                                          color: scheme.onSurfaceVariant),
                                                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      GlassCard(
                        radius: 36,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // «Ручка» шторки
                            Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: scheme.onSurface.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _ModeSwitch(),
                            const SizedBox(height: 16),
                            const _Field(
                              label: 'E-mail',
                              hint: 'ana.rusu@student.utm.md',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            const _Field(
                              label: 'Пароль',
                              hint: 'Пароль',
                              obscure: true,
                            ),
                            const SizedBox(height: 20),
                            PillButton(
                              label: 'Войти',
                              icon: Icons.arrow_forward_rounded,
                              // Без проверки полей (L2) — просто открываем приложение
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeShell(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Нет аккаунта?', style: text.bodySmall),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Зарегистрируйтесь'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: -6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text('Вход', style: text.labelLarge),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Регистрация',
                  style: text.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6),
          child: SectionLabel(label),
        ),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surfaceContainerLowest.withValues(alpha: 0.75),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: border,
            enabledBorder: border,
            focusedBorder:
                border.copyWith(borderSide: BorderSide(color: scheme.primary)),
          ),
        ),
      ],
    );
  }
}