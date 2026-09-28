
/// Пользователь
class User {
  final int id;
  final String email;
  final String name;

  const User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
      );
}

/// Упражнение — сущность
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

/// Тренировочная сессия — сущность
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


const mockUser = User(id: 1, email: 'ana.rusu@student.utm.md', name: 'Ана Русу');

/// Группы мышц для фильтра в каталоге
const muscleGroups = ['Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Кардио'];

final mockExercises = [
  Exercise(
    id: 1,
    name: 'Жим штанги лёжа',
    muscleGroup: 'Грудь',
    description:
        'Базовое упражнение для большой грудной мышцы, передних дельт и трицепса.',
    technique: 'Лягте на скамью, лопатки сведены, стопы упираются в пол.\n'
        'Возьмите гриф хватом чуть шире плеч.\n'
        'На вдохе опустите штангу к нижней части груди.\n'
        'На выдохе выжмите штангу вверх.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 2,
    name: 'Отжимания на брусьях с наклоном вперёд',
    muscleGroup: 'Грудь',
    description:
        'Упражнение с собственным весом с акцентом на нижнюю часть груди.',
    technique: 'Упритесь руками в брусья, корпус наклонён вперёд.\n'
        'Опуститесь до угла 90° в локтях.\n'
        'Выжмите себя вверх, не выпрямляя корпус.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 3,
    name: 'Приседания со штангой',
    muscleGroup: 'Ноги',
    description:
        'Главное упражнение для квадрицепсов и ягодиц. Дополнительно нагружает мышцы кора и спины.',
    technique: 'Штанга на трапециях, стопы на ширине плеч.\n'
        'Отведите таз назад и опуститесь до параллели бедра с полом.\n'
        'Колени идут по направлению носков, спина прямая.\n'
        'Поднимитесь, отталкиваясь всей стопой.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 4,
    name: 'Выпады с гантелями',
    muscleGroup: 'Ноги',
    description:
        'Одностороннее упражнение для ног: развивает баланс и убирает асимметрию.',
    technique: 'Встаньте прямо, гантели в опущенных руках.\n'
        'Сделайте широкий шаг вперёд и опуститесь.\n'
        'Вернитесь в исходное положение и смените ногу.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 5,
    name: 'Подтягивания широким хватом',
    muscleGroup: 'Спина',
    description: 'Базовое упражнение для широчайших мышц спины и бицепса.',
    technique: 'Возьмитесь за перекладину хватом шире плеч.\n'
        'Сведите лопатки и подтянитесь до уровня подбородка.\n'
        'Медленно опуститесь до полного выпрямления рук.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 6,
    name: 'Жим гантелей сидя',
    muscleGroup: 'Плечи',
    description: 'Развивает передние и средние пучки дельтовидных мышц.',
    technique: 'Сядьте на скамью с вертикальной спинкой.\n'
        'Гантели на уровне плеч, ладони вперёд.\n'
        'Выжмите гантели вверх, не соударяя их.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 7,
    name: 'Подъём штанги на бицепс',
    muscleGroup: 'Руки',
    description: 'Классическое изолирующее упражнение для бицепса.',
    technique: 'Стоя, штанга в опущенных руках хватом снизу.\n'
        'Согните руки в локтях, не раскачивая корпус.\n'
        'Медленно опустите штангу.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 8,
    name: 'Планка на локтях',
    muscleGroup: 'Пресс',
    description: 'Статическое упражнение для мышц кора: пресс, косые, поясница.',
    technique: 'Упор на предплечья и носки, тело — прямая линия.\n'
        'Напрягите пресс и ягодицы, не прогибайтесь в пояснице.\n'
        'Удерживайте положение 30–60 секунд.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
  Exercise(
    id: 9,
    name: 'Интервальный бег',
    muscleGroup: 'Кардио',
    description: 'Чередование быстрого и медленного темпа для выносливости.',
    technique: 'Разминка 5 минут в спокойном темпе.\n'
        '8 интервалов: 1 минута быстро / 2 минуты шагом.\n'
        'Заминка 5 минут.',
    imageUrl: '',
    createdAt: DateTime(2026, 9, 1),
  ),
];

/// Сессии в обратном хронологическом порядке новые сверху
final mockSessions = [
  WorkoutSession(
    id: 8, userId: 1, date: DateTime(2026, 9, 22),
    exerciseIds: [3, 4, 8], durationMin: 75,
    notes: 'Приседания 4×8 по 70 кг — новый рекорд.',
    createdAt: DateTime(2026, 9, 22, 19, 40),
  ),
  WorkoutSession(
    id: 7, userId: 1, date: DateTime(2026, 9, 20),
    exerciseIds: [1, 2, 6], durationMin: 68,
    notes: 'Жим 5×5 по 55 кг, плечи немного устали.',
    createdAt: DateTime(2026, 9, 20, 12, 15),
  ),
  WorkoutSession(
    id: 6, userId: 1, date: DateTime(2026, 9, 18),
    exerciseIds: [9], durationMin: 35,
    notes: 'Лёгкое кардио после пар.',
    createdAt: DateTime(2026, 9, 18, 18, 5),
  ),
  WorkoutSession(
    id: 5, userId: 1, date: DateTime(2026, 9, 16),
    exerciseIds: [5, 7], durationMin: 70,
    notes: 'Подтягивания: 4 подхода по 7 раз.',
    createdAt: DateTime(2026, 9, 16, 20, 30),
  ),
  WorkoutSession(
    id: 4, userId: 1, date: DateTime(2026, 9, 13),
    exerciseIds: [3, 4], durationMin: 60,
    notes: '',
    createdAt: DateTime(2026, 9, 13, 11, 0),
  ),
  WorkoutSession(
    id: 3, userId: 1, date: DateTime(2026, 9, 10),
    exerciseIds: [1, 6, 8], durationMin: 80,
    notes: 'Долгая тренировка, в зале было много людей.',
    createdAt: DateTime(2026, 9, 10, 19, 20),
  ),
  WorkoutSession(
    id: 2, userId: 1, date: DateTime(2026, 9, 6),
    exerciseIds: [5, 7], durationMin: 55,
    notes: 'Работала над техникой подтягиваний.',
    createdAt: DateTime(2026, 9, 6, 10, 45),
  ),
  WorkoutSession(
    id: 1, userId: 1, date: DateTime(2026, 9, 2),
    exerciseIds: [9, 8], durationMin: 40,
    notes: 'Первая тренировка семестра.',
    createdAt: DateTime(2026, 9, 2, 17, 10),
  ),
];

/// Поиск упражнения по id
Exercise exerciseById(int id) => mockExercises.firstWhere((e) => e.id == id);