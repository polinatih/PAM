// Проверки форматирования и границы JSON (L5).
// mock-данные удалены вместе с mock-репозиториями — тесты проверяют
// то, что пережило переход на бэкенд: format.dart и fromJson/toJson.

import 'package:flutter_test/flutter_test.dart';

import 'package:fit_track/data/exercise.dart';
import 'package:fit_track/data/format.dart';
import 'package:fit_track/data/workout_session.dart';

void main() {
  test('formatDuration переводит минуты в «ч мин»', () {
    expect(formatDuration(40), '40 мин');
    expect(formatDuration(120), '2 ч');
    expect(formatDuration(483), '8 ч 03 мин');
  });

  test('Exercise.fromJson читает ответ GET /exercises/{id}', () {
    final e = Exercise.fromJson({
      'id': 3,
      'name': 'Приседания со штангой',
      'muscleGroup': 'Ноги',
      'description': 'Главное упражнение для ног.',
      'technique': 'Шаг 1\nШаг 2',
      'imageUrl': '',
      'createdAt': '2026-09-01T10:00:00.000Z',
    });
    expect(e.id, 3);
    expect(e.techniqueSteps, ['Шаг 1', 'Шаг 2']);
  });

  test('WorkoutSession: fromJson → toJson без id и userId', () {
    final s = WorkoutSession.fromJson({
      'id': 8,
      'userId': 1,
      'date': '2026-09-22',
      'exerciseIds': [3, 4, 8],
      'durationMin': 75,
      'notes': 'Новый рекорд',
      'createdAt': '2026-09-22T19:40:00.000Z',
    });
    expect(s.exerciseIds, [3, 4, 8]);
    expect(s.toJson(), {
      'date': '2026-09-22',
      'exerciseIds': [3, 4, 8],
      'durationMin': 75,
      'notes': 'Новый рекорд',
    });
  });
}
