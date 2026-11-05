// Доменная модель тренировочной сессии (L4): отдельный файл, который переживёт mock.
// Поля = JSON сущности /workout-sessions на бэкенде.

class WorkoutSession {
  final int id;
  final int userId;
  final DateTime date;
  final List<int> exerciseIds;
  final int durationMin;
  final String notes;
  final DateTime createdAt;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.exerciseIds,
    required this.durationMin,
    required this.notes,
    required this.createdAt,
  });

  /// «Та же сессия, другая идентичность»: id выдаёт хранилище
  /// (на L4 — mock-репозиторий, на L5 — сервер).
  WorkoutSession copyWith({int? id}) => WorkoutSession(
        id: id ?? this.id,
        userId: userId,
        date: date,
        exerciseIds: exerciseIds,
        durationMin: durationMin,
        notes: notes,
        createdAt: createdAt,
      );

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as int,
        userId: json['userId'] as int,
        date: DateTime.parse(json['date'] as String),
        exerciseIds: (json['exerciseIds'] as List).cast<int>(),
        durationMin: json['durationMin'] as int,
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
