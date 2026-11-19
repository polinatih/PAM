import 'exercise.dart';
import 'result.dart';

/// Контракт хранилища упражнений (вторая сущность темы).
/// В приложении каталог только читается, поэтому в контракте чтение:
///   fetchAll()  → GET /exercises?page=&limit=&search=&muscleGroup=
///   fetchById() → GET /exercises/{id}   (404 → Err)
///
/// L5: fetchAll вырос опциональными именованными параметрами — старый вызов
/// fetchAll() из L4 компилируется без изменений.
abstract class ExerciseRepository {
  Future<Result<List<Exercise>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? muscleGroup,
  });
  Future<Result<Exercise>> fetchById(int id);
}
