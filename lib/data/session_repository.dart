import 'result.dart';
import 'workout_session.dart';

/// Контракт хранилища тренировочных сессий: ЧТО можно просить, а не КАК.
/// На L5 каждый метод один-к-одному ложится на REST-контракт бэкенда:
///   fetchAll()   → GET    /workout-sessions        (список из конверта)
///   fetchById()  → GET    /workout-sessions/{id}   (404 → Err)
///   create()     → POST   /workout-sessions        (201, id даёт сервер)
///   update()     → PUT    /workout-sessions/{id}   (заменяет по id)
///   delete()     → DELETE /workout-sessions/{id}   (204, пустое тело)
abstract class SessionRepository {
  Future<Result<List<WorkoutSession>>> fetchAll();
  Future<Result<WorkoutSession>> fetchById(int id);
  Future<Result<WorkoutSession>> create(WorkoutSession session);
  Future<Result<WorkoutSession>> update(WorkoutSession session);
  Future<Result<void>> delete(int id);
}
