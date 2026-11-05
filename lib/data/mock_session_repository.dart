import 'mock_data.dart';
import 'result.dart';
import 'session_repository.dart';
import 'workout_session.dart';

/// Mock-реализация хранилища сессий: память + задержка сети + авария.
/// Единственный файл (вместе с mock-репозиторием упражнений), который
/// видит seed-данные. На L5 его место займёт HttpSessionRepository.
class MockSessionRepository implements SessionRepository {
  final List<WorkoutSession> _sessions = List.of(mockSessions); // seed из L2
  int _nextId = 1000; // выше любого id из seed-а

  /// Авария: включена → любой вызов проваливается (переключатель в профиле).
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Тренировка не существует';

  /// Новые сверху — так же, как будет отдавать сервер.
  static int _newestFirst(WorkoutSession a, WorkoutSession b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }

  @override
  Future<Result<List<WorkoutSession>>> fetchAll() async {
    await Future.delayed(_latency); // сеть не отвечает мгновенно — и мы не будем
    if (simulateError) return const Err(_errNetwork);
    final list = List.of(_sessions)..sort(_newestFirst);
    return Ok(list); // копия — внутренний список не отдаётся из рук
  }

  @override
  Future<Result<WorkoutSession>> fetchById(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return const Err(_errNotFound); // «404» mock-а
    return Ok(_sessions[index]);
  }

  @override
  Future<Result<WorkoutSession>> create(WorkoutSession session) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final created = session.copyWith(id: _nextId++); // id даёт ХРАНИЛИЩЕ
    _sessions.add(created);
    return Ok(created);
  }

  @override
  Future<Result<WorkoutSession>> update(WorkoutSession session) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) return const Err(_errNotFound);
    _sessions[index] = session; // заменяет по id — как PUT
    return Ok(session);
  }

  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return const Err(_errNotFound);
    _sessions.removeAt(index);
    return const Ok(null); // «удалил, отдать нечего» — 204 в типах
  }
}
