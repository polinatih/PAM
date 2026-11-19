// FitTrack: каталог упражнений — CRUD по образцу lib/notes.dart.
//
// Отличие от notes: упражнения — общий справочник (без user_id), его видит
// каждый вошедший пользователь. Маршруты всё равно под requireAuth.
// Дополнительно к контракту: фильтр ?muscleGroup= (из ТЗ темы).

import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'name': row['name'],
      'muscleGroup': row['muscle_group'],
      'description': row['description'],
      'technique': row['technique'],
      'imageUrl': row['image_url'],
      'createdAt': row['created_at'],
    };

Row? _find(String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select('SELECT * FROM exercises WHERE id = ?', [id]);
  return rows.isEmpty ? null : rows.first;
}

/// GET /exercises?page=1&limit=20&search=&muscleGroup=
///   -> {items, page, limit, total}
///
/// Поиск — по названию и описанию, без учёта регистра. Фильтрация делается
/// в Dart, а не через SQL LIKE: LIKE в SQLite не понижает регистр кириллицы
/// («жим» не нашёл бы «Жим»). Справочник маленький, так что это дёшево.
Future<Response> listExercises(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100).toInt();
  final search = (query['search'] ?? '').trim().toLowerCase();
  final group = (query['muscleGroup'] ?? '').trim();

  final all = db.select('SELECT * FROM exercises ORDER BY id ASC');
  final matching = all.where((row) {
    if (group.isNotEmpty && row['muscle_group'] != group) return false;
    if (search.isEmpty) return true;
    final name = (row['name'] as String).toLowerCase();
    final description = (row['description'] as String).toLowerCase();
    return name.contains(search) || description.contains(search);
  }).toList();

  final start = min((page - 1) * limit, matching.length);
  final end = min(start + limit, matching.length);

  return jsonResponse({
    'items': matching.sublist(start, end).map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': matching.length,
  });
}

/// Общая проверка тела для POST и PUT. null — тело валидно.
String? _validate(Map<String, dynamic> body) {
  if (stringField(body, 'name') == null) return 'name is required';
  if (stringField(body, 'muscleGroup') == null) {
    return 'muscleGroup is required';
  }
  for (final key in ['description', 'technique', 'imageUrl']) {
    if (body[key] != null && body[key] is! String) {
      return '$key must be a string';
    }
  }
  return null;
}

String _text(Map<String, dynamic> body, String key) =>
    body[key] is String ? body[key] as String : '';

/// POST /exercises  {name, muscleGroup, description?, technique?, imageUrl?}
///   -> 201 exercise
Future<Response> createExercise(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final problem = _validate(body);
  if (problem != null) return validationError(problem);

  db.execute(
    'INSERT INTO exercises '
    '(name, muscle_group, description, technique, image_url, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [
      stringField(body, 'name'),
      stringField(body, 'muscleGroup'),
      _text(body, 'description'),
      _text(body, 'technique'),
      _text(body, 'imageUrl'),
      nowIso(),
    ],
  );
  final row = _find('${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /exercises/{id} -> 200 exercise | 404
Future<Response> getExercise(Request request) async {
  final row = _find(request.params['id']);
  if (row == null) return notFound('Exercise not found');
  return jsonResponse(_toJson(row));
}

/// PUT /exercises/{id}  (то же тело, что у POST) -> 200 | 404
Future<Response> updateExercise(Request request) async {
  final row = _find(request.params['id']);
  if (row == null) return notFound('Exercise not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final problem = _validate(body);
  if (problem != null) return validationError(problem);

  db.execute(
    'UPDATE exercises SET name = ?, muscle_group = ?, description = ?, '
    'technique = ?, image_url = ? WHERE id = ?',
    [
      stringField(body, 'name'),
      stringField(body, 'muscleGroup'),
      _text(body, 'description'),
      _text(body, 'technique'),
      _text(body, 'imageUrl'),
      row['id'],
    ],
  );
  return jsonResponse(_toJson(_find('${row['id']}')!));
}

/// DELETE /exercises/{id} -> 204 | 404
Future<Response> deleteExercise(Request request) async {
  final row = _find(request.params['id']);
  if (row == null) return notFound('Exercise not found');
  db.execute('DELETE FROM exercises WHERE id = ?', [row['id']]);
  return Response(204);
}

// ---------------------------------------------------------------------------
// Начальное наполнение справочника — при первом запуске, если таблица пуста.
// 24 упражнения: больше одной страницы (20), чтобы была видна пагинация.
// ---------------------------------------------------------------------------

void seedExercises() {
  final count =
      db.select('SELECT COUNT(*) AS n FROM exercises').first['n'] as int;
  if (count > 0) return;

  for (final e in _seed) {
    db.execute(
      'INSERT INTO exercises '
      '(name, muscle_group, description, technique, image_url, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [e[0], e[1], e[2], e[3], '', nowIso()],
    );
  }
}

/// [название, группа мышц, описание, техника (шаги через \n)]
const _seed = <List<String>>[
  ['Жим штанги лёжа', 'Грудь',
    'Базовое упражнение для большой грудной мышцы, передних дельт и трицепса.',
    'Лягте на скамью, лопатки сведены, стопы упираются в пол.\nВозьмите гриф хватом чуть шире плеч.\nНа вдохе опустите штангу к нижней части груди.\nНа выдохе выжмите штангу вверх.'],
  ['Отжимания на брусьях с наклоном вперёд', 'Грудь',
    'Упражнение с собственным весом с акцентом на нижнюю часть груди.',
    'Упритесь руками в брусья, корпус наклонён вперёд.\nОпуститесь до угла 90° в локтях.\nВыжмите себя вверх, не выпрямляя корпус.'],
  ['Приседания со штангой', 'Ноги',
    'Главное упражнение для квадрицепсов и ягодиц. Дополнительно нагружает мышцы кора и спины.',
    'Штанга на трапециях, стопы на ширине плеч.\nОтведите таз назад и опуститесь до параллели бедра с полом.\nКолени идут по направлению носков, спина прямая.\nПоднимитесь, отталкиваясь всей стопой.'],
  ['Выпады с гантелями', 'Ноги',
    'Одностороннее упражнение для ног: развивает баланс и убирает асимметрию.',
    'Встаньте прямо, гантели в опущенных руках.\nСделайте широкий шаг вперёд и опуститесь.\nВернитесь в исходное положение и смените ногу.'],
  ['Подтягивания широким хватом', 'Спина',
    'Базовое упражнение для широчайших мышц спины и бицепса.',
    'Возьмитесь за перекладину хватом шире плеч.\nСведите лопатки и подтянитесь до уровня подбородка.\nМедленно опуститесь до полного выпрямления рук.'],
  ['Жим гантелей сидя', 'Плечи',
    'Развивает передние и средние пучки дельтовидных мышц.',
    'Сядьте на скамью с вертикальной спинкой.\nГантели на уровне плеч, ладони вперёд.\nВыжмите гантели вверх, не соударяя их.'],
  ['Подъём штанги на бицепс', 'Руки',
    'Классическое изолирующее упражнение для бицепса.',
    'Стоя, штанга в опущенных руках хватом снизу.\nСогните руки в локтях, не раскачивая корпус.\nМедленно опустите штангу.'],
  ['Планка на локтях', 'Пресс',
    'Статическое упражнение для мышц кора: пресс, косые, поясница.',
    'Упор на предплечья и носки, тело — прямая линия.\nНапрягите пресс и ягодицы, не прогибайтесь в пояснице.\nУдерживайте положение 30–60 секунд.'],
  ['Интервальный бег', 'Кардио',
    'Чередование быстрого и медленного темпа для выносливости.',
    'Разминка 5 минут в спокойном темпе.\n8 интервалов: 1 минута быстро / 2 минуты шагом.\nЗаминка 5 минут.'],
  ['Жим гантелей на наклонной скамье', 'Грудь',
    'Смещает нагрузку на верхнюю часть грудных мышц.',
    'Установите скамью под углом 30–45°.\nОпустите гантели к верхней части груди.\nВыжмите их вверх по дуге.'],
  ['Разводка гантелей лёжа', 'Грудь',
    'Изолирующее упражнение для растяжения и проработки грудных мышц.',
    'Лягте на скамью, гантели над грудью, локти слегка согнуты.\nРазведите руки в стороны до лёгкого растяжения.\nСведите гантели обратно.'],
  ['Становая тяга', 'Спина',
    'Базовое упражнение для задней поверхности тела: спина, ягодицы, бицепс бедра.',
    'Стопы на ширине таза, гриф над серединой стопы.\nВозьмитесь за гриф, спина прямая.\nВыпрямитесь, разгибая ноги и таз одновременно.\nОпустите штангу по той же траектории.'],
  ['Тяга верхнего блока к груди', 'Спина',
    'Аналог подтягиваний на тренажёре, удобен для новичков.',
    'Сядьте, зафиксируйте бёдра валиками.\nТяните рукоять к верхней части груди, сводя лопатки.\nПлавно верните рукоять вверх.'],
  ['Тяга гантели в наклоне', 'Спина',
    'Прорабатывает широчайшие и ромбовидные мышцы по одной стороне за раз.',
    'Упритесь коленом и рукой в скамью, спина прямая.\nТяните гантель к поясу, локоть вдоль корпуса.\nПлавно опустите гантель.'],
  ['Румынская тяга', 'Ноги',
    'Акцент на бицепс бедра и ягодицы при прямых ногах.',
    'Встаньте прямо, штанга в руках.\nОтводя таз назад, опустите штангу вдоль ног до середины голени.\nВернитесь в исходное положение, напрягая ягодицы.'],
  ['Жим ногами в тренажёре', 'Ноги',
    'Нагружает квадрицепсы без осевой нагрузки на позвоночник.',
    'Сядьте в тренажёр, стопы на платформе на ширине плеч.\nОпустите платформу до угла 90° в коленях.\nВыжмите платформу, не выпрямляя колени до конца.'],
  ['Подъём на носки стоя', 'Ноги',
    'Изолированная проработка икроножных мышц.',
    'Встаньте носками на возвышение.\nПоднимитесь на носки как можно выше.\nМедленно опуститесь, растягивая икры.'],
  ['Армейский жим стоя', 'Плечи',
    'Базовое упражнение для плеч и стабилизаторов корпуса.',
    'Штанга на уровне ключиц, хват чуть шире плеч.\nВыжмите штангу над головой, не прогибаясь в пояснице.\nОпустите штангу обратно к ключицам.'],
  ['Махи гантелями в стороны', 'Плечи',
    'Изолирующее упражнение для средних пучков дельт.',
    'Стоя, гантели вдоль корпуса.\nПоднимите руки в стороны до уровня плеч.\nМедленно опустите гантели.'],
  ['Французский жим', 'Руки',
    'Изолирующее упражнение для трицепса.',
    'Лягте на скамью, штанга над лбом на прямых руках.\nСгибая локти, опустите штангу ко лбу.\nРазогните руки, локти неподвижны.'],
  ['Молотковые сгибания', 'Руки',
    'Прорабатывают бицепс и плечевую мышцу нейтральным хватом.',
    'Стоя, гантели в руках ладонями к корпусу.\nСогните руки, не разворачивая кисти.\nПлавно опустите гантели.'],
  ['Скручивания', 'Пресс',
    'Базовое упражнение для прямой мышцы живота.',
    'Лягте на спину, колени согнуты.\nНа выдохе оторвите лопатки от пола.\nМедленно вернитесь назад.'],
  ['Подъём ног в висе', 'Пресс',
    'Нагружает нижнюю часть пресса и сгибатели бедра.',
    'Повисните на перекладине.\nПоднимите прямые ноги до параллели с полом.\nМедленно опустите ноги без раскачки.'],
  ['Гребной тренажёр', 'Кардио',
    'Кардионагрузка с участием спины, ног и рук.',
    'Сядьте, закрепите стопы.\nОттолкнитесь ногами, затем потяните рукоять к поясу.\nВернитесь в обратном порядке: руки, корпус, ноги.'],
];
