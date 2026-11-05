import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/format.dart';
import '../data/workout_session.dart';
import '../models/exercises_model.dart';
import '../models/sessions_model.dart';
import '../widgets/filter_pill.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_label.dart';

/// Форма новой сессии / редактирования.
/// Валидация и контроллеры — из L3 (без изменений); с L4 валидный submit
/// ПИШЕТ через SessionsModel → repository, и все подписанные экраны
/// (дневник, статистика, профиль, бейдж) обновляются сами.
/// /diary/new — новая сессия (POST /workout-sessions на L5),
/// /diary/:id — редактирование (PUT / DELETE на L5).
class SessionFormScreen extends StatefulWidget {
  final int? sessionId;

  const SessionFormScreen({super.key, this.sessionId});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры создаёт State — он же их и освобождает в dispose()
  final _dateCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _date;
  late Set<int> _selectedIds;

  WorkoutSession? _session; // null — новая сессия
  bool get _isEdit => _session != null;
  bool _missing = false; // в адресе id, которого нет в дневнике

  /// Идёт «запрос» — кнопки гаснут (эфемерное состояние → setState).
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Экран получает из адреса только id и ищет сессию через модель
    // (read: однократное чтение, а не подписка)
    if (widget.sessionId != null) {
      _session = context.read<SessionsModel>().byId(widget.sessionId!);
      _missing = _session == null;
    }
    final now = DateTime.now();
    _date = _session?.date ?? DateTime(now.year, now.month, now.day);
    _selectedIds = {...?_session?.exerciseIds};
    _dateCtrl.text = formatDateShort(_date);
    _durationCtrl.text = '${_session?.durationMin ?? 60}';
    _notesCtrl.text = _session?.notes ?? '';
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Действия
  // ---------------------------------------------------------------------------

  /// Кнопки «− / +»: меняют длительность на 5 минут в пределах 1–600.
  void _changeDuration(int delta) {
    final current = int.tryParse(_durationCtrl.text) ?? 0;
    final next = (current + delta).clamp(1, 600);
    _durationCtrl.text = '$next';
  }

  /// Выбор даты через календарь; будущие даты недоступны.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = formatDateShort(picked);
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  /// Submit: валидирует → пишет через модель → закрывает форму.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // валидация L3, нетронута

    final draft = WorkoutSession(
      id: _session?.id ?? 0, // 0 — временный: настоящий id даст хранилище
      userId: _session?.userId ?? 0, // на L5 владельца определит сервер
      date: _date,
      exerciseIds: _selectedIds.toList()..sort(),
      durationMin: int.parse(_durationCtrl.text),
      notes: _notesCtrl.text.trim(),
      createdAt: _session?.createdAt ?? DateTime.now(),
    );

    setState(() => _busy = true);
    final model = context.read<SessionsModel>(); // read: это действие
    final error = _isEdit ? await model.update(draft) : await model.add(draft);
    if (!mounted) return; // экран может умереть, пока «запрос» летит
    setState(() => _busy = false);

    if (error != null) {
      _showSnack(error); // данные остаются в полях
      return;
    }
    _showSnack(_isEdit
        ? 'Сессия обновлена: ${draft.durationMin} мин'
        : 'Сессия сохранена: ${draft.durationMin} мин');
    context.pop(); // дневник позади УЖЕ обновлён — notifyListeners
  }

  /// Удаление — деструктивное действие, поэтому сначала диалог.
  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить тренировку?'),
        content: Text(
          'Сессию от ${formatDateShort(_date)} нельзя будет восстановить.',
        ),
        actions: [
          TextButton(
            // dialogCtx, а не context экрана: закрываем именно диалог
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    // ok == true, а не ok!: диалог, закрытый мимо, возвращает null
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    final error = await context.read<SessionsModel>().remove(_session!.id);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      _showSnack(error);
      return;
    }
    _showSnack('Сессия удалена');
    context.pop(); // объекта больше нет — его экран уходит из стека
  }

  // ---------------------------------------------------------------------------
  // Валидаторы: null — значит поле ВАЛИДНО
  // ---------------------------------------------------------------------------

  String? _validateDate(String? _) {
    final today = DateTime.now();
    if (_date.isAfter(DateTime(today.year, today.month, today.day))) {
      return 'Дата не может быть в будущем';
    }
    return null;
  }

  String? _validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) return 'Укажите длительность';
    final minutes = int.tryParse(value);
    if (minutes == null) return 'Введите целое число минут';
    if (minutes < 1) return 'Минимум 1 минута';
    if (minutes > 600) return 'Не больше 600 минут';
    return null;
  }

  String? _validateExercises(Set<int>? value) {
    if (value == null || value.isEmpty) {
      return 'Выберите хотя бы одно упражнение';
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final catalog = context.watch<ExercisesModel>(); // список для выбора

    // Старая ссылка или удалённая сессия: id в адресе есть, сессии нет
    if (_missing) {
      return Scaffold(
        body: GlassBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Тренировка не существует', style: text.bodyLarge),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/diary'),
                  child: const Text('К дневнику'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                // Верхняя панель: закрыть · режим · удалить
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Закрыть',
                      onPressed: () => context.pop(),
                    ),
                    SectionLabel(_isEdit ? 'Редактирование' : 'Новая сессия'),
                    if (_isEdit)
                      GlassIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Удалить сессию',
                        onPressed: _busy ? null : _delete,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _isEdit ? 'Изменить\nтренировку' : 'Запишите\nтренировку',
                    style: text.headlineMedium,
                  ),
                ),
                const SizedBox(height: 22),

                // Дата: только чтение, по нажатию — календарь
                GlassCard(
                  radius: 26,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 20, color: scheme.primary),
                      const SizedBox(width: 14),
                      const SectionLabel('Дата'),
                      Expanded(
                        child: TextFormField(
                          controller: _dateCtrl,
                          readOnly: true,
                          onTap: _pickDate,
                          validator: _validateDate,
                          textAlign: TextAlign.end,
                          style: text.bodyLarge,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Длительность: числовая клавиатура, только цифры, 1–600
                GlassCard(
                  radius: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Длительность, мин'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassIconButton(
                            icon: Icons.remove_rounded,
                            tooltip: 'Меньше на 5 минут',
                            onPressed: () => _changeDuration(-5),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _durationCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.center,
                              style: text.displayLarge,
                              validator: _validateDuration,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                errorMaxLines: 2,
                              ),
                            ),
                          ),
                          GlassIconButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Больше на 5 минут',
                            onPressed: () => _changeDuration(5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Упражнения: поле выбора, тоже с validator (минимум одно)
                GlassCard(
                  radius: 30,
                  child: FormField<Set<int>>(
                    initialValue: _selectedIds,
                    validator: _validateExercises,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: SectionLabel('Упражнения')),
                            SectionLabel(
                              'Выбрано · ${_selectedIds.length}',
                              color: scheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (catalog.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(),
                              ),
                            for (final e in catalog.all)
                              FilterPill(
                                label: e.name,
                                selected: _selectedIds.contains(e.id),
                                accent: true,
                                onTap: () {
                                  setState(() {
                                    if (!_selectedIds.remove(e.id)) {
                                      _selectedIds.add(e.id);
                                    }
                                  });
                                  field.didChange({..._selectedIds});
                                },
                              ),
                          ],
                        ),
                        // Ошибка выбора — красным под чипами
                        if (field.hasError) ...[
                          const SizedBox(height: 10),
                          Text(
                            field.errorText!,
                            style: text.bodySmall
                                ?.copyWith(color: scheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Заметки: необязательны, до 500 символов
                GlassCard(
                  radius: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Заметки'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesCtrl,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        textInputAction: TextInputAction.done,
                        style: text.bodyLarge,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Веса, подходы, самочувствие…',
                          hintStyle: text.bodyLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PillButton(
                  label: _isEdit ? 'Сохранить изменения' : 'Сохранить сессию',
                  icon: Icons.check_rounded,
                  onPressed: _busy ? null : _save, // без двойного submit
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
