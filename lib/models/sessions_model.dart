import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../data/session_repository.dart';
import '../data/workout_session.dart';

/// Разделяемое состояние темы: дневник тренировок (пункт L4 FitTrack).
/// Его читают дневник, статистика, профиль и бейдж в меню — поэтому одна
/// модель на всех. Хранилище входит через конструктор (DI).
class SessionsModel extends ChangeNotifier {
  SessionsModel(this._repository);

  final SessionRepository _repository; // тип — ИНТЕРФЕЙС, а не mock!

  bool _loading = false;
  String? _error;
  List<WorkoutSession> _sessions = const [];

  bool get isLoading => _loading;
  String? get error => _error;

  /// Наружу — только для чтения: мутации идут через методы, которые извещают.
  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  int get totalMinutes =>
      _sessions.fold<int>(0, (sum, s) => sum + s.durationMin);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); // «грузится»

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _sessions = _sorted(value);
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners(); // данные или ошибка — никогда молча
  }

  /// Ищет в загруженном списке; null — нет.
  WorkoutSession? byId(int id) {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Мутации: через хранилище, с извещением.
  // Возврат: null — успех, строка — сообщение об ошибке (как у validator).
  // ---------------------------------------------------------------------------

  Future<String?> add(WorkoutSession draft) async {
    switch (await _repository.create(draft)) {
      case Ok(:final value):
        _sessions = _sorted([..._sessions, value]); // с id от хранилища
        notifyListeners(); // дневник, статистика, профиль, бейдж — узнают все
        return null;
      case Err(:final msg):
        return msg; // состояние нетронуто — экран решает, что показать
    }
  }

  Future<String?> update(WorkoutSession session) async {
    switch (await _repository.update(session)) {
      case Ok(:final value):
        _sessions = _sorted([
          for (final s in _sessions) s.id == value.id ? value : s,
        ]);
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _sessions = _sessions.where((s) => s.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  /// Новые сверху.
  static List<WorkoutSession> _sorted(List<WorkoutSession> list) {
    final copy = List.of(list);
    copy.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    return copy;
  }
}
