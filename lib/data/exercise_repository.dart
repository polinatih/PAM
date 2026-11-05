import 'exercise.dart';
import 'result.dart';

/// Контракт хранилища упражнений (вторая сущность темы).
/// В приложении каталог только читается, поэтому в контракте чтение:
///   fetchAll()  → GET /exercises        (список из конверта)
///   fetchById() → GET /exercises/{id}   (404 → Err)
abstract class ExerciseRepository {
  Future<Result<List<Exercise>>> fetchAll();
  Future<Result<Exercise>> fetchById(int id);
}
