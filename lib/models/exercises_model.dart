import 'package:flutter/foundation.dart';

import '../data/exercise.dart';
import '../data/exercise_repository.dart';
import '../data/result.dart';

/// Состояние каталога упражнений + триада «грузится / данные / ошибка» (C8).
/// Хранилище входит через конструктор: модель не знает, mock это или http.
///
/// L5: поверх состояния L4 — поиск, фильтр по группе и ломти (пагинация).
/// Плюс «словарь» всех упражнений: по нему дневник и статистика берут
/// названия, а форма — список для выбора, независимо от фильтра каталога.
class ExercisesModel extends ChangeNotifier {
  ExercisesModel(this._repository); // простой DI

  final ExerciseRepository _repository; // тип — ИНТЕРФЕЙС, а не mock!

  static const _limit = 20; // размер ломтя

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  List<Exercise> _exercises = const []; // текущий список каталога (ломти)
  final Map<int, Exercise> _known = {}; // словарь: все полученные упражнения

  String _search = '';
  String _muscleGroup = ''; // '' — все группы
  int _page = 1;

  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get search => _search;
  String get muscleGroup => _muscleGroup;

  /// Список для каталога — только для чтения.
  List<Exercise> get exercises => List.unmodifiable(_exercises);

  /// Все известные упражнения — для формы сессии и счётчиков.
  List<Exercise> get all {
    final list = _known.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(list);
  }

  /// Первая страница с текущими (или новыми) фильтрами.
  /// [search]/[muscleGroup]: null — оставить прежний, '' — сбросить.
  /// Retry вызывает load() без аргументов — фильтр сохраняется.
  Future<void> load({String? search, String? muscleGroup}) async {
    _search = search ?? _search;
    _muscleGroup = muscleGroup ?? _muscleGroup;
    _page = 1;
    _loading = true;
    _error = null;
    notifyListeners(); // «грузится»

    // Словарь — один раз: максимум 100 записей без фильтров
    if (_known.isEmpty) {
      final dictionary = await _repository.fetchAll(limit: 100);
      if (dictionary case Ok(:final value)) _remember(value);
    }

    switch (await _repository.fetchAll(
      page: 1,
      limit: _limit,
      search: _search,
      muscleGroup: _muscleGroup,
    )) {
      case Ok(:final value):
        _exercises = value;
        _remember(value);
        _hasMore = value.length == _limit; // полная страница → видимо, есть ещё
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners(); // данные или ошибка — никогда молча
  }

  /// Следующий ломоть. Вызывается из itemBuilder — в разгар build, поэтому
  /// _loadingMore = true ставится БЕЗ notifyListeners (иначе «setState()
  /// called during build»), а guard не даёт запросить страницу дважды.
  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    _loadingMore = true;

    switch (await _repository.fetchAll(
      page: _page + 1,
      limit: _limit,
      search: _search,
      muscleGroup: _muscleGroup,
    )) {
      case Ok(:final value):
        _page += 1;
        _exercises = [..._exercises, ...value]; // страница приклеивается
        _remember(value);
        _hasMore = value.length == _limit;
      case Err():
        _hasMore = false; // хвост перестаёт просить; retry — через поиск
    }
    _loadingMore = false;
    notifyListeners();
  }

  /// Ищет в словаре; null — нет (ещё грузится или не существует).
  Exercise? byId(int id) => _known[id];

  void _remember(List<Exercise> list) {
    for (final e in list) {
      _known[e.id] = e;
    }
  }
}
