// Зашитые в код данные (L2). На L4 их заменит Repository, на L5 — backend.

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String description;
  final List<String> technique;
  final String equipment;
  final String difficulty;
  final String imageUrl; // на L2 вместо изображения — иконка группы мышц

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    required this.technique,
    required this.equipment,
    required this.difficulty,
    this.imageUrl = '',
  });
}

class WorkoutSession {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> exerciseIds;
  final int durationMin;
  final String notes;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    required this.exerciseIds,
    required this.durationMin,
    required this.notes,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String group;
  final int weeklyGoal;
  final double weightKg;
  final int heightCm;

  const UserProfile({
    required this.name,
    required this.email,
    required this.group,
    required this.weeklyGoal,
    required this.weightKg,
    required this.heightCm,
  });
}

class WeekStat {
  final String label;
  final int sessions;
  final int minutes;
  const WeekStat(this.label, this.sessions, this.minutes);
}

const muscleGroups = [
  'Все',
  'Грудь',
  'Спина',
  'Ноги',
  'Плечи',
  'Руки',
  'Пресс',
  'Кардио',
];

const mockExercises = [
  Exercise(
    id: 'e1',
    name: 'Жим штанги лёжа',
    muscleGroup: 'Грудь',
    description:
        'Базовое упражнение для развития большой грудной мышцы, передних дельт и трицепса.',
    technique: [
      'Лягте на скамью, лопатки сведены, стопы упираются в пол.',
      'Возьмите гриф хватом чуть шире плеч и снимите со стоек.',
      'На вдохе опустите штангу к нижней части груди.',
      'На выдохе выжмите штангу вверх до полного выпрямления рук.',
    ],
    equipment: 'Штанга, скамья',
    difficulty: 'Средняя',
  ),
  Exercise(
    id: 'e2',
    name: 'Отжимания на брусьях с наклоном корпуса вперёд',
    muscleGroup: 'Грудь',
    description:
        'Упражнение с собственным весом, акцент на нижнюю часть грудных мышц.',
    technique: [
      'Упритесь руками в брусья, корпус наклонён вперёд.',
      'Опуститесь до угла 90° в локтях.',
      'Мощно выжмите себя вверх, не выпрямляя корпус.',
    ],
    equipment: 'Брусья',
    difficulty: 'Средняя',
  ),
  Exercise(
    id: 'e3',
    name: 'Приседания со штангой на спине',
    muscleGroup: 'Ноги',
    description:
        'Главное упражнение для квадрицепсов и ягодиц, также нагружает мышцы кора.',
    technique: [
      'Штанга лежит на трапециях, стопы на ширине плеч.',
      'Отведите таз назад и опуститесь до параллели бедра с полом.',
      'Колени идут по направлению носков.',
      'Поднимитесь, отталкиваясь всей стопой.',
    ],
    equipment: 'Штанга, силовая рама',
    difficulty: 'Высокая',
  ),
  Exercise(
    id: 'e4',
    name: 'Выпады с гантелями',
    muscleGroup: 'Ноги',
    description:
        'Одностороннее упражнение для ног, развивает баланс и устраняет асимметрию.',
    technique: [
      'Встаньте прямо, гантели в опущенных руках.',
      'Сделайте широкий шаг вперёд и опуститесь, заднее колено почти касается пола.',
      'Вернитесь в исходное положение и смените ногу.',
    ],
    equipment: 'Гантели',
    difficulty: 'Низкая',
  ),
  Exercise(
    id: 'e5',
    name: 'Подтягивания широким хватом',
    muscleGroup: 'Спина',
    description:
        'Базовое упражнение для широчайших мышц спины и бицепса.',
    technique: [
      'Возьмитесь за перекладину хватом шире плеч.',
      'Сведите лопатки и подтянитесь до уровня подбородка.',
      'Медленно опуститесь до полного выпрямления рук.',
    ],
    equipment: 'Турник',
    difficulty: 'Высокая',
  ),
  Exercise(
    id: 'e6',
    name: 'Тяга гантели в наклоне',
    muscleGroup: 'Спина',
    description:
        'Прорабатывает широчайшие и ромбовидные мышцы, по одной стороне за раз.',
    technique: [
      'Упритесь коленом и рукой в скамью, спина прямая.',
      'Тяните гантель к поясу, локоть идёт вдоль корпуса.',
      'Плавно опустите гантель вниз.',
    ],
    equipment: 'Гантель, скамья',
    difficulty: 'Низкая',
  ),
  Exercise(
    id: 'e7',
    name: 'Жим гантелей сидя',
    muscleGroup: 'Плечи',
    description:
        'Развивает передние и средние пучки дельтовидных мышц.',
    technique: [
      'Сядьте на скамью с вертикальной спинкой.',
      'Гантели на уровне плеч, ладони вперёд.',
      'Выжмите гантели вверх, не соударяя их.',
    ],
    equipment: 'Гантели, скамья',
    difficulty: 'Средняя',
  ),
  Exercise(
    id: 'e8',
    name: 'Подъём штанги на бицепс',
    muscleGroup: 'Руки',
    description: 'Классическое изолирующее упражнение для бицепса.',
    technique: [
      'Стоя, штанга в опущенных руках хватом снизу.',
      'Согните руки в локтях, не раскачивая корпус.',
      'Медленно опустите штангу.',
    ],
    equipment: 'Штанга (EZ-гриф)',
    difficulty: 'Низкая',
  ),
  Exercise(
    id: 'e9',
    name: 'Планка на локтях',
    muscleGroup: 'Пресс',
    description:
        'Статическое упражнение для мышц кора: пресс, косые, поясница.',
    technique: [
      'Упор на предплечья и носки, тело — прямая линия.',
      'Напрягите пресс и ягодицы, не прогибайтесь в пояснице.',
      'Удерживайте положение 30–60 секунд.',
    ],
    equipment: 'Коврик',
    difficulty: 'Низкая',
  ),
  Exercise(
    id: 'e10',
    name: 'Интервальный бег на дорожке',
    muscleGroup: 'Кардио',
    description:
        'Чередование быстрого и медленного темпа для развития выносливости.',
    technique: [
      'Разминка 5 минут в спокойном темпе.',
      '8 интервалов: 1 минута быстро / 2 минуты шагом.',
      'Заминка 5 минут.',
    ],
    equipment: 'Беговая дорожка',
    difficulty: 'Средняя',
  ),
];

// Сессии — в обратном хронологическом порядке (сначала новые).
final mockSessions = [
  WorkoutSession(
    id: 's8',
    userId: 'u1',
    date: DateTime(2026, 9, 22),
    exerciseIds: ['e3', 'e4', 'e9'],
    durationMin: 75,
    notes: 'Приседания 4×8 по 70 кг — новый рекорд!',
  ),
  WorkoutSession(
    id: 's7',
    userId: 'u1',
    date: DateTime(2026, 9, 20),
    exerciseIds: ['e1', 'e2', 'e7'],
    durationMin: 68,
    notes: 'Жим 5×5 по 55 кг, плечи немного устали.',
  ),
  WorkoutSession(
    id: 's6',
    userId: 'u1',
    date: DateTime(2026, 9, 18),
    exerciseIds: ['e10'],
    durationMin: 35,
    notes: 'Лёгкое кардио после пар.',
  ),
  WorkoutSession(
    id: 's5',
    userId: 'u1',
    date: DateTime(2026, 9, 16),
    exerciseIds: ['e5', 'e6', 'e8'],
    durationMin: 70,
    notes: 'Подтягивания: 4 подхода по 7 раз.',
  ),
  WorkoutSession(
    id: 's4',
    userId: 'u1',
    date: DateTime(2026, 9, 13),
    exerciseIds: ['e3', 'e4'],
    durationMin: 60,
    notes: '',
  ),
  WorkoutSession(
    id: 's3',
    userId: 'u1',
    date: DateTime(2026, 9, 10),
    exerciseIds: ['e1', 'e7', 'e9'],
    durationMin: 80,
    notes: 'Долгая тренировка, в зале было много людей.',
  ),
  WorkoutSession(
    id: 's2',
    userId: 'u1',
    date: DateTime(2026, 9, 6),
    exerciseIds: ['e5', 'e6'],
    durationMin: 55,
    notes: 'Работал над техникой тяги.',
  ),
  WorkoutSession(
    id: 's1',
    userId: 'u1',
    date: DateTime(2026, 9, 2),
    exerciseIds: ['e10', 'e9'],
    durationMin: 40,
    notes: 'Первая тренировка семестра.',
  ),
];

const mockWeeks = [
  WeekStat('1–7 сен', 2, 95),
  WeekStat('8–14 сен', 2, 140),
  WeekStat('15–21 сен', 3, 173),
  WeekStat('22–28 сен', 1, 75),
];

const mockUser = UserProfile(
  name: 'Ана Русу',
  email: 'ana.rusu@student.utm.md',
  group: 'TI-236',
  weeklyGoal: 3,
  weightKg: 74.5,
  heightCm: 181,
);

Exercise exerciseById(String id) =>
    mockExercises.firstWhere((e) => e.id == id);
