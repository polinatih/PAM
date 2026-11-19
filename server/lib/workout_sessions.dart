// FitTrack: тренировочные сессии — CRUD по образцу lib/notes.dart.
//
// Сессия принадлежит пользователю (user_id), как заметка в шаблоне:
// чужая сессия неотличима от несуществующей (404, а не 403).

import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'userId': row['user_id'],
      'date': row['date'],
      'exerciseIds':
          (jsonDecode(row['exercise_ids'] as String) as List).cast<int>(),
      'durationMin': row['duration_min'],
      'notes': row['notes'],
      'createdAt': row['created_at'],
    };

/// Ищет сессию по id, но только среди сессий текущего пользователя.
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM workout_sessions WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

/// GET /workout-sessions?page=1&limit=20&search=  -> {items, page, limit, total}
/// Новые сверху (по дате, затем по id). Поиск — по заметкам, без учёта
/// регистра (в Dart: LIKE в SQLite не понижает регистр кириллицы).
Future<Response> listSessions(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100).toInt();
  final search = (query['search'] ?? '').trim().toLowerCase();

  final all = db.select(
    'SELECT * FROM workout_sessions WHERE user_id = ? '
    'ORDER BY date DESC, id DESC',
    [currentUserId(request)],
  );
  final matching = search.isEmpty
      ? all.toList()
      : all
          .where((row) =>
              (row['notes'] as String).toLowerCase().contains(search))
          .toList();

  final start = min((page - 1) * limit, matching.length);
  final end = min(start + limit, matching.length);

  return jsonResponse({
    'items': matching.sublist(start, end).map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': matching.length,
  });
}

/// Проверенные поля сессии — или сообщение об ошибке.
typedef _Fields = ({
  String? error,
  String date,
  List<int> exerciseIds,
  int durationMin,
  String notes,
});

/// Общая проверка тела для POST и PUT (правила — как в форме приложения).
_Fields _validate(Map<String, dynamic> body) {
  _Fields fail(String message) => (
        error: message,
        date: '',
        exerciseIds: const <int>[],
        durationMin: 0,
        notes: '',
      );

  // date: строка формата YYYY-MM-DD
  final rawDate = stringField(body, 'date');
  final parsed = rawDate == null ? null : DateTime.tryParse(rawDate);
  if (parsed == null) return fail('date must be a date (YYYY-MM-DD)');
  final date = parsed.toIso8601String().substring(0, 10);

  // durationMin: целое число 1–600
  final duration = body['durationMin'];
  if (duration is! int || duration < 1 || duration > 600) {
    return fail('durationMin must be an integer between 1 and 600');
  }

  // exerciseIds: непустой список id существующих упражнений
  final rawIds = body['exerciseIds'];
  if (rawIds is! List || rawIds.isEmpty || rawIds.any((e) => e is! int)) {
    return fail('exerciseIds must be a non-empty list of integers');
  }
  final ids = rawIds.cast<int>();
  for (final id in ids) {
    final exists =
        db.select('SELECT id FROM exercises WHERE id = ?', [id]).isNotEmpty;
    if (!exists) return fail('exercise $id does not exist');
  }

  // notes: необязательная строка до 500 символов
  final notes = body['notes'] is String ? body['notes'] as String : '';
  if (notes.length > 500) return fail('notes must be at most 500 characters');

  return (
    error: null,
    date: date,
    exerciseIds: ids,
    durationMin: duration,
    notes: notes,
  );
}

/// POST /workout-sessions  {date, exerciseIds, durationMin, notes?} -> 201
Future<Response> createSession(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final f = _validate(body);
  if (f.error != null) return validationError(f.error!);

  db.execute(
    'INSERT INTO workout_sessions '
    '(user_id, date, exercise_ids, duration_min, notes, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [
      currentUserId(request),
      f.date,
      jsonEncode(f.exerciseIds),
      f.durationMin,
      f.notes,
      nowIso(),
    ],
  );
  final row = _find(currentUserId(request), '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /workout-sessions/{id} -> 200 | 404
Future<Response> getSession(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Workout session not found');
  return jsonResponse(_toJson(row));
}

/// PUT /workout-sessions/{id}  (то же тело, что у POST) -> 200 | 404
Future<Response> updateSession(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Workout session not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final f = _validate(body);
  if (f.error != null) return validationError(f.error!);

  db.execute(
    'UPDATE workout_sessions SET date = ?, exercise_ids = ?, '
    'duration_min = ?, notes = ? WHERE id = ?',
    [f.date, jsonEncode(f.exerciseIds), f.durationMin, f.notes, row['id']],
  );
  final updated = _find(currentUserId(request), '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /workout-sessions/{id} -> 204 | 404
Future<Response> deleteSession(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Workout session not found');
  db.execute('DELETE FROM workout_sessions WHERE id = ?', [row['id']]);
  return Response(204);
}
