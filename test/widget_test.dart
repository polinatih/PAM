// Простые проверки mock-данных и форматирования (L2).
// Виджет-тесты экранов появятся на L6.

import 'package:flutter_test/flutter_test.dart';

import 'package:fit_track/data/format.dart';
import 'package:fit_track/data/mock_data.dart';

void main() {
  test('formatDuration переводит минуты в «ч мин»', () {
    expect(formatDuration(40), '40 мин');
    expect(formatDuration(120), '2 ч');
    expect(formatDuration(483), '8 ч 03 мин');
  });

  test('в каждом списке не меньше 6 элементов (требование L2)', () {
    expect(mockExercises.length, greaterThanOrEqualTo(6));
    expect(mockSessions.length, greaterThanOrEqualTo(6));
  });

  test('сессии ссылаются только на существующие упражнения', () {
    final ids = mockExercises.map((e) => e.id).toSet();
    for (final s in mockSessions) {
      expect(ids.containsAll(s.exerciseIds), isTrue);
    }
  });
}
