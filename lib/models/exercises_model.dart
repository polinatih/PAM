import 'package:flutter/foundation.dart';

import '../data/exercise.dart';
import '../data/exercise_repository.dart';
import '../data/result.dart';

/// Состояние каталога упражнений + триада «грузится / данные / ошибка» (C8).
/// Хранилище входит через конструктор: модель не знает, mock это или http.
class ExercisesModel extends ChangeNotifier {
  ExercisesModel(this._repository); // простой DI

  final ExerciseRepository _repository; // тип — ИНТЕРФЕЙС, а не mock!

  bool _loading = false;
  String? _error;
  List<Exercise> _exercises = const [];

  bool get isLoading => _loading;
  String? get error => _error;

  /// Список для каталога — только для чтения.
  List<Exercise> get exercises => List.unmodifiable(_exercises);

  /// Все известные упражнения — для формы сессии и счётчиков.
  List<Exercise> get all => List.unmodifiable(_exercises);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); // подписанные экраны входят в состояние «грузится»

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _exercises = value;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners(); // …и выходят: с данными или с ошибкой — никогда молча
  }

  /// Ищет в загруженном списке; null — нет (ещё грузится или не существует).
  Exercise? byId(int id) {
    for (final e in _exercises) {
      if (e.id == id) return e;
    }
    return null;
  }
}
