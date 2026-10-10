import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/arc_ring.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_label.dart';

/// Экран входа / регистрации — локальная валидация (L3).
/// Поля = тело запросов бэкенда: POST /auth/login {email, password},
/// POST /auth/register {email, password, name}.
/// Реальной проверки пользователя нет — она придёт на L5 (backend + JWT):
/// любые данные, прошедшие валидацию, впускают в приложение.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры живут в State и освобождаются в dispose()
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isRegister = false; // false — «Вход», true — «Регистрация»
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _setMode(bool register) {
    setState(() => _isRegister = register);
    _formKey.currentState?.reset(); // убираем ошибки прошлого режима
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return; // ошибки уже на экране
    if (_isRegister) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Аккаунт создан: ${_nameCtrl.text.trim()}'),
        ),
      );
    }
    // go, НЕ push: экран входа уходит из стека,
    // и кнопка «назад» не вернёт вошедшего пользователя на логин
    context.go('/exercises');
  }

  // ---------------------------------------------------------------------------
  // Валидаторы: null — значит поле ВАЛИДНО
  // ---------------------------------------------------------------------------

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите имя';
    if (value.trim().length < 2) return 'Имя слишком короткое';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Введите e-mail';
    // Правдоподобный формат: что-то@что-то.домен
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) return 'Неверный формат e-mail';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Минимум 6 символов';
    return null;
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          // SliverFillRemaining: на весь экран, но прокручивается,
          // когда клавиатура поднимается и места не хватает.
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // «Ручка» шторки
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _ModeSwitch(
                                isRegister: _isRegister,
                                onChanged: _setMode,
                              ),
                              const SizedBox(height: 16),

                              // Имя — только при регистрации (его требует
                              // POST /auth/register)
                              if (_isRegister) ...[
                                _Field(
                                  label: 'Имя',
                                  hint: 'Ана Русу',
                                  controller: _nameCtrl,
                                  validator: _validateName,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 14),
                              ],
                              _Field(
                                label: 'E-mail',
                                hint: 'ana.rusu@student.utm.md',
                                controller: _emailCtrl,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              _Field(
                                label: 'Пароль',
                                hint: 'Не меньше 6 символов',
                                controller: _passwordCtrl,
                                validator: _validatePassword,
                                obscure: _hidePassword,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                suffix: IconButton(
                                  tooltip: _hidePassword
                                      ? 'Показать пароль'
                                      : 'Скрыть пароль',
                                  onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword),
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              PillButton(
                                label: _isRegister
                                    ? 'Зарегистрироваться'
                                    : 'Войти',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isRegister
                                        ? 'Уже есть аккаунт?'
                                        : 'Нет аккаунта?',
                                    style: text.bodySmall,
                                  ),
                                  TextButton(
                                    onPressed: () => _setMode(!_isRegister),
                                    child: Text(_isRegister
                                        ? 'Войдите'
                                        : 'Зарегистрируйтесь'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

/// Переключатель «Вход / Регистрация».
class _ModeSwitch extends StatelessWidget {
  final bool isRegister;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({required this.isRegister, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _segment(context, 'Вход', !isRegister, () => onChanged(false)),
          _segment(context, 'Регистрация', isRegister, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _segment(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? scheme.surfaceContainerLowest
                : scheme.surfaceContainerLowest.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: -6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: selected
                ? text.labelLarge
                : text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

/// Поле ввода с подписью капсом сверху; ошибка validator-а — красным снизу.
class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
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
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autocorrect: false,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            suffixIcon: suffix,
            filled: true,
            fillColor: scheme.surfaceContainerLowest.withValues(alpha: 0.75),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: border,
            enabledBorder: border,
            focusedBorder:
                border.copyWith(borderSide: BorderSide(color: scheme.primary)),
            errorBorder:
                border.copyWith(borderSide: BorderSide(color: scheme.error)),
            focusedErrorBorder:
                border.copyWith(borderSide: BorderSide(color: scheme.error)),
          ),
        ),
      ],
    );
  }
}
