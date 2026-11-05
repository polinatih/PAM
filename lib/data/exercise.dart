// Доменная модель упражнения (L4): отдельный файл, который переживёт mock.
// Поля = JSON сущности /exercises на бэкенде.

/// Группы мышц — часть домена, а не mock-данных.
const muscleGroups = ['Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Кардио'];

class Exercise {
  final int id;
  final String name;
  final String muscleGroup;
  final String description;
  final String technique; // шаги техники, каждый с новой строки
  final String imageUrl;
  final DateTime createdAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    required this.technique,
    required this.imageUrl,
    required this.createdAt,
  });

  /// Шаги техники списком
  List<String> get techniqueSteps =>
      technique.split('\n').where((s) => s.trim().isNotEmpty).toList();

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as int,
        name: json['name'] as String,
        muscleGroup: json['muscleGroup'] as String,
        description: json['description'] as String? ?? '',
        technique: json['technique'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
