import 'exercise.dart';
import 'exercise_repository.dart';
import 'mock_data.dart';
import 'result.dart';

/// Mock-реализация хранилища упражнений: память + задержка сети + авария.
/// На L5 её место займёт HttpExerciseRepository.
class MockExerciseRepository implements ExerciseRepository {
  final List<Exercise> _exercises = List.of(mockExercises); // seed из L2

  /// Авария: включена → любой вызов проваливается (переключатель в профиле).
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';

  @override
  Future<Result<List<Exercise>>> fetchAll() async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    return Ok(List.of(_exercises)); // копия, а не внутренний список
  }

  @override
  Future<Result<Exercise>> fetchById(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index == -1) return const Err('Упражнение не существует');
    return Ok(_exercises[index]);
  }
}
