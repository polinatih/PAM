// Набор проверок соответствия контракту backend-а FitTrack.
//
// Официальный набор conformance из шаблона не был выдан, поэтому проверки
// написаны по контракту, который реализует шаблон (README, errors.dart,
// auth.dart, notes.dart, files.dart), плюс проверки сущностей темы.
//
// Запуск (сервер должен быть запущен):
//   cd conformance
//   dart run bin/conformance.dart --base-url http://localhost:8080
//
// Зависимостей нет — только dart:io и dart:convert.

import 'dart:convert';
import 'dart:io';

late final String baseUrl;
final _client = HttpClient();

int _passed = 0;
int _failed = 0;
int _skipped = 0;

// ---------------------------------------------------------------------------
// HTTP
// ---------------------------------------------------------------------------

class Res {
  Res(this.status, this.body, this.headers);
  final int status;
  final String body;
  final HttpHeaders headers;

  /// Тело как JSON (null, если это не JSON).
  dynamic get json {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  /// Код ошибки из стандартного конверта {"error": {"code", "message"}}.
  String? get errorCode {
    final j = json;
    if (j is Map && j['error'] is Map) return j['error']['code'] as String?;
    return null;
  }
}

Future<Res> call(String method, String path,
    {Object? body, String? token, String? rawBody}) async {
  final req = await _client.openUrl(method, Uri.parse('$baseUrl$path'));
  if (token != null) req.headers.set('Authorization', 'Bearer $token');
  if (body != null || rawBody != null) {
    req.headers.contentType = ContentType.json;
    req.add(utf8.encode(rawBody ?? jsonEncode(body)));
  }
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  return Res(res.statusCode, text, res.headers);
}

/// multipart/form-data с одним полем [field].
Future<Res> upload(String path, String token,
    {String field = 'file', required String filename,
    required String mime, required List<int> bytes}) async {
  const boundary = '----fittrack-conformance-boundary';
  final req = await _client.postUrl(Uri.parse('$baseUrl$path'));
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');
  req.add(utf8.encode('--$boundary\r\n'
      'Content-Disposition: form-data; name="$field"; filename="$filename"\r\n'
      'Content-Type: $mime\r\n\r\n'));
  req.add(bytes);
  req.add(utf8.encode('\r\n--$boundary--\r\n'));
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  return Res(res.statusCode, text, res.headers);
}

// ---------------------------------------------------------------------------
// Мини-фреймворк проверок
// ---------------------------------------------------------------------------

class Fail implements Exception {
  Fail(this.message);
  final String message;
}

void expect(bool condition, String message) {
  if (!condition) throw Fail(message);
}

void expectStatus(Res r, int status, [String? code]) {
  expect(r.status == status,
      'ожидался статус $status, пришёл ${r.status}: ${_short(r.body)}');
  if (code != null) {
    expect(r.errorCode == code,
        'ожидался код ошибки $code, пришёл ${r.errorCode}: ${_short(r.body)}');
  }
}

String _short(String s) => s.length > 160 ? '${s.substring(0, 160)}…' : s;

void group(String title) => stdout.writeln('\n\x1B[1m$title\x1B[0m');

Future<void> check(String name, Future<void> Function() body) async {
  try {
    await body();
    _passed++;
    stdout.writeln('  \x1B[32m✓\x1B[0m $name');
  } on Fail catch (e) {
    _failed++;
    stdout.writeln('  \x1B[31m✗\x1B[0m $name\n      → ${e.message}');
  } catch (e) {
    _failed++;
    stdout.writeln('  \x1B[31m✗\x1B[0m $name\n      → исключение: $e');
  }
}

void skip(String name, String why) {
  _skipped++;
  stdout.writeln('  \x1B[33m–\x1B[0m $name (пропущено: $why)');
}

// ---------------------------------------------------------------------------
// Проверки
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  final i = args.indexOf('--base-url');
  baseUrl = (i >= 0 && i + 1 < args.length ? args[i + 1] : 'http://localhost:8080')
      .replaceAll(RegExp(r'/$'), '');
  stdout.writeln('FitTrack conformance → $baseUrl');

  try {
    await call('GET', '/health');
  } on SocketException {
    stdout.writeln('\nСервер не отвечает на $baseUrl — запустите его (dart run).');
    exit(2);
  }

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final emailA = 'a$stamp@test.md';
  final emailB = 'b$stamp@test.md';
  const password = 'secret123';
  late String tokenA;
  late String tokenB;

  // ------------------------------------------------------------- база: общее
  group('Базовый контракт: общее');

  await check('GET /health → 200 {"status":"ok"}', () async {
    final r = await call('GET', '/health');
    expectStatus(r, 200);
    expect(r.json is Map && r.json['status'] == 'ok', 'тело: ${r.body}');
  });

  await check('неизвестный маршрут → 404 NOT_FOUND в стандартном конверте',
      () async {
    final r = await call('GET', '/no-such-route-$stamp');
    expectStatus(r, 404, 'NOT_FOUND');
    expect(r.json['error']['message'] is String, 'нет error.message');
  });

  await check('ответы — application/json', () async {
    final r = await call('GET', '/health');
    expect(r.headers.contentType?.mimeType == 'application/json',
        'content-type: ${r.headers.contentType}');
  });

  // --------------------------------------------------------------- база: auth
  group('Базовый контракт: аутентификация');

  await check('POST /auth/register → 201 {token, user{id,email,name}}', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': emailA, 'password': password, 'name': 'Alice'});
    expectStatus(r, 201);
    final j = r.json;
    expect(j['token'] is String && (j['token'] as String).split('.').length == 3,
        'token — не JWT');
    expect(j['user']['id'] is int, 'user.id не int');
    expect(j['user']['email'] == emailA && j['user']['name'] == 'Alice',
        'user: ${j['user']}');
    expect(!(j['user'] as Map).containsKey('password') &&
        !(j['user'] as Map).containsKey('password_hash'),
        'пароль утёк в ответ');
    tokenA = j['token'] as String;
  });

  await check('второй пользователь регистрируется', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': emailB, 'password': password, 'name': 'Bob'});
    expectStatus(r, 201);
    tokenB = r.json['token'] as String;
  });

  await check('повторный email → 409 EMAIL_TAKEN', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': emailA, 'password': password, 'name': 'Alice'});
    expectStatus(r, 409, 'EMAIL_TAKEN');
  });

  await check('register без name / с плохим email → 400 VALIDATION_ERROR',
      () async {
    final r1 = await call('POST', '/auth/register',
        body: {'email': 'x$stamp@test.md', 'password': password});
    expectStatus(r1, 400, 'VALIDATION_ERROR');
    final r2 = await call('POST', '/auth/register',
        body: {'email': 'not-an-email', 'password': password, 'name': 'X'});
    expectStatus(r2, 400, 'VALIDATION_ERROR');
  });

  await check('register с телом не-JSON → 400 VALIDATION_ERROR', () async {
    final r = await call('POST', '/auth/register', rawBody: 'not json');
    expectStatus(r, 400, 'VALIDATION_ERROR');
  });

  await check('POST /auth/login → 200 {token, user}', () async {
    final r = await call('POST', '/auth/login',
        body: {'email': emailA, 'password': password});
    expectStatus(r, 200);
    expect(r.json['token'] is String, 'нет token');
    expect(r.json['user']['email'] == emailA, 'user: ${r.json['user']}');
  });

  await check('login с неверным паролем → 401 UNAUTHORIZED', () async {
    final r = await call('POST', '/auth/login',
        body: {'email': emailA, 'password': 'wrong-password'});
    expectStatus(r, 401, 'UNAUTHORIZED');
  });

  await check('login с неизвестным email → 401 UNAUTHORIZED', () async {
    final r = await call('POST', '/auth/login',
        body: {'email': 'nobody$stamp@test.md', 'password': password});
    expectStatus(r, 401, 'UNAUTHORIZED');
  });

  await check('GET /me с token → 200 {id, email, name}', () async {
    final r = await call('GET', '/me', token: tokenA);
    expectStatus(r, 200);
    expect(r.json['email'] == emailA && r.json['name'] == 'Alice',
        'тело: ${r.body}');
  });

  await check('GET /me без token → 401 UNAUTHORIZED', () async {
    expectStatus(await call('GET', '/me'), 401, 'UNAUTHORIZED');
  });

  await check('GET /me с испорченным token → 401 UNAUTHORIZED', () async {
    final broken = '${tokenA.substring(0, tokenA.length - 2)}xx';
    expectStatus(await call('GET', '/me', token: broken), 401, 'UNAUTHORIZED');
    expectStatus(await call('GET', '/me', token: 'abc'), 401, 'UNAUTHORIZED');
  });

  // -------------------------------------------------------------- база: notes
  group('Базовый контракт: notes (сущность-образец)');

  late int noteId;
  await check('POST /notes → 201 {id, title, content, createdAt}', () async {
    final r = await call('POST', '/notes',
        token: tokenA, body: {'title': 'Первая $stamp', 'content': 'текст'});
    expectStatus(r, 201);
    expect(r.json['id'] is int && r.json['title'] == 'Первая $stamp',
        'тело: ${r.body}');
    expect(r.json['createdAt'] is String, 'нет createdAt');
    noteId = r.json['id'] as int;
  });

  await check('POST /notes без title → 400 VALIDATION_ERROR', () async {
    final r = await call('POST', '/notes', token: tokenA, body: {'content': 'x'});
    expectStatus(r, 400, 'VALIDATION_ERROR');
  });

  await check('POST /notes без token → 401', () async {
    expectStatus(await call('POST', '/notes', body: {'title': 'x'}), 401,
        'UNAUTHORIZED');
  });

  await check('GET /notes → конверт {items, page, limit, total}', () async {
    for (var n = 0; n < 3; n++) {
      await call('POST', '/notes', token: tokenA, body: {'title': 'Ещё $n'});
    }
    final r = await call('GET', '/notes?page=1&limit=2', token: tokenA);
    expectStatus(r, 200);
    final j = r.json;
    expect(j['items'] is List && (j['items'] as List).length == 2,
        'items на странице: ${(j['items'] as List?)?.length}');
    expect(j['page'] == 1 && j['limit'] == 2, 'page/limit: $j');
    expect(j['total'] == 4, 'total = ${j['total']}, ожидалось 4');
  });

  await check('GET /notes?page=2 — следующая страница', () async {
    final r = await call('GET', '/notes?page=2&limit=2', token: tokenA);
    expectStatus(r, 200);
    expect((r.json['items'] as List).length == 2, 'тело: ${_short(r.body)}');
  });

  await check('GET /notes?search= фильтрует', () async {
    final r = await call('GET',
        '/notes?search=${Uri.encodeQueryComponent('Первая')}', token: tokenA);
    expectStatus(r, 200);
    expect(r.json['total'] == 1, 'total = ${r.json['total']}');
  });

  await check('GET /notes/{id} → 200, PUT → 200, DELETE → 204, затем 404',
      () async {
    expectStatus(await call('GET', '/notes/$noteId', token: tokenA), 200);
    final put = await call('PUT', '/notes/$noteId',
        token: tokenA, body: {'title': 'Изменена', 'content': ''});
    expectStatus(put, 200);
    expect(put.json['title'] == 'Изменена', 'PUT не применился');
    final del = await call('DELETE', '/notes/$noteId', token: tokenA);
    expectStatus(del, 204);
    expect(del.body.isEmpty, '204 с телом');
    expectStatus(
        await call('GET', '/notes/$noteId', token: tokenA), 404, 'NOT_FOUND');
  });

  await check('чужая заметка неотличима от отсутствующей → 404', () async {
    final r = await call('GET', '/notes', token: tokenA);
    final id = (r.json['items'] as List).first['id'];
    expectStatus(await call('GET', '/notes/$id', token: tokenB), 404, 'NOT_FOUND');
    final listB = await call('GET', '/notes', token: tokenB);
    expect(listB.json['total'] == 0, 'B видит заметки A');
  });

  // -------------------------------------------------------------- база: files
  group('Базовый контракт: files');

  await check('POST /files (multipart) → 201, GET /files/{id} отдаёт байты',
      () async {
    final bytes = utf8.encode('hello fittrack $stamp');
    final r = await upload('/files', tokenA,
        filename: 'hello.txt', mime: 'text/plain', bytes: bytes);
    expectStatus(r, 201);
    final j = r.json;
    expect(j['id'] is int && j['url'] == '/files/${j['id']}', 'тело: ${r.body}');
    expect(j['size'] == bytes.length && j['mimeType'] == 'text/plain',
        'size/mimeType: ${r.body}');
    final get = await call('GET', '/files/${j['id']}');
    expectStatus(get, 200);
    expect(get.body == 'hello fittrack $stamp', 'байты не совпали');
    expect((get.headers.value('content-disposition') ?? '')
        .contains('attachment'), 'нет Content-Disposition: attachment');
  });

  await check('POST /files без поля file → 400 VALIDATION_ERROR', () async {
    final r = await upload('/files', tokenA, field: 'other',
        filename: 'x.txt', mime: 'text/plain', bytes: [1, 2, 3]);
    expectStatus(r, 400, 'VALIDATION_ERROR');
  });

  await check('POST /files без token → 401', () async {
    final r = await call('POST', '/files', rawBody: '{}');
    expectStatus(r, 401, 'UNAUTHORIZED');
  });

  await check('GET /files/{несуществующий} → 404', () async {
    expectStatus(await call('GET', '/files/999999999'), 404, 'NOT_FOUND');
  });

  // ----------------------------------------------------- тема: exercises
  group('Сущность темы: exercises (каталог упражнений)');

  final probeEx = await call('GET', '/exercises', token: tokenA);
  if (probeEx.status == 404) {
    skip('все проверки /exercises', 'маршрут ещё не добавлен');
  } else {
    await check('GET /exercises без token → 401', () async {
      expectStatus(await call('GET', '/exercises'), 401, 'UNAUTHORIZED');
    });

    await check('GET /exercises → конверт, в каталоге ≥ 24 упражнений', () async {
      final r = await call('GET', '/exercises?limit=100', token: tokenA);
      expectStatus(r, 200);
      expect(r.json['total'] is int && r.json['total'] >= 24,
          'total = ${r.json['total']}');
      final e = (r.json['items'] as List).first as Map;
      for (final key in ['id', 'name', 'muscleGroup', 'description',
          'technique', 'imageUrl', 'createdAt']) {
        expect(e.containsKey(key), 'у упражнения нет поля $key');
      }
    });

    await check('пагинация: limit=20 → 20, page=2 → остаток', () async {
      final all = await call('GET', '/exercises?limit=100', token: tokenA);
      final total = all.json['total'] as int;
      final p1 = await call('GET', '/exercises?page=1&limit=20', token: tokenA);
      final p2 = await call('GET', '/exercises?page=2&limit=20', token: tokenA);
      expect((p1.json['items'] as List).length == 20, 'страница 1');
      expect((p2.json['items'] as List).length == total - 20, 'страница 2');
    });

    await check('?search= ищет без учёта регистра (кириллица)', () async {
      final lower = await call('GET',
          '/exercises?search=${Uri.encodeQueryComponent('жим')}', token: tokenA);
      final upper = await call('GET',
          '/exercises?search=${Uri.encodeQueryComponent('ЖИМ')}', token: tokenA);
      expectStatus(lower, 200);
      expect(lower.json['total'] > 0, '«жим» ничего не нашёл');
      expect(lower.json['total'] == upper.json['total'],
          '«жим» и «ЖИМ» дали разный результат');
    });

    await check('?muscleGroup= фильтрует по группе мышц', () async {
      final r = await call('GET',
          '/exercises?limit=100&muscleGroup=${Uri.encodeQueryComponent('Ноги')}',
          token: tokenA);
      expectStatus(r, 200);
      final items = r.json['items'] as List;
      expect(items.isNotEmpty, 'пусто');
      expect(items.every((e) => e['muscleGroup'] == 'Ноги'), 'чужая группа в выдаче');
    });

    await check('GET /exercises/{id} → 200, несуществующий → 404', () async {
      expectStatus(await call('GET', '/exercises/1', token: tokenA), 200);
      expectStatus(await call('GET', '/exercises/999999', token: tokenA), 404,
          'NOT_FOUND');
    });

    await check('POST /exercises без name → 400 VALIDATION_ERROR', () async {
      final r = await call('POST', '/exercises',
          token: tokenA, body: {'muscleGroup': 'Ноги'});
      expectStatus(r, 400, 'VALIDATION_ERROR');
    });

    await check('POST → 201, PUT → 200, DELETE → 204, затем 404', () async {
      final c = await call('POST', '/exercises', token: tokenA,
          body: {'name': 'Тест $stamp', 'muscleGroup': 'Кор'});
      expectStatus(c, 201);
      final id = c.json['id'];
      final u = await call('PUT', '/exercises/$id', token: tokenA,
          body: {'name': 'Тест изменён', 'muscleGroup': 'Кор'});
      expectStatus(u, 200);
      expect(u.json['name'] == 'Тест изменён', 'PUT не применился');
      expectStatus(await call('DELETE', '/exercises/$id', token: tokenA), 204);
      expectStatus(await call('GET', '/exercises/$id', token: tokenA), 404);
    });
  }

  // ----------------------------------------------- тема: workout-sessions
  group('Сущность темы: workout-sessions (дневник тренировок)');

  final probeWs = await call('GET', '/workout-sessions', token: tokenA);
  if (probeWs.status == 404) {
    skip('все проверки /workout-sessions', 'маршрут ещё не добавлен');
  } else {
    Map<String, Object?> session(String date, {int duration = 45, String notes = ''}) =>
        {'date': date, 'durationMin': duration, 'exerciseIds': [1, 2], 'notes': notes};

    await check('GET /workout-sessions без token → 401', () async {
      expectStatus(await call('GET', '/workout-sessions'), 401, 'UNAUTHORIZED');
    });

    late int sessionId;
    await check('POST → 201, id и userId выдаёт сервер', () async {
      final r = await call('POST', '/workout-sessions',
          token: tokenA, body: session('2026-11-10', notes: 'Ноги, рекорд'));
      expectStatus(r, 201);
      final j = r.json;
      expect(j['id'] is int && j['userId'] is int, 'тело: ${r.body}');
      expect(j['date'] == '2026-11-10' && j['durationMin'] == 45, 'тело: ${r.body}');
      expect((j['exerciseIds'] as List).length == 2, 'exerciseIds: ${j['exerciseIds']}');
      sessionId = j['id'] as int;
    });

    await check('валидация: плохая дата / длительность / пустой список → 400',
        () async {
      final bad = <Map<String, Object?>>[
        {...session('плохо')},
        {...session('2026-11-10', duration: 0)},
        {...session('2026-11-10', duration: 601)},
        {...session('2026-11-10'), 'exerciseIds': <int>[]},
        {...session('2026-11-10'), 'exerciseIds': [999999]},
        {...session('2026-11-10'), 'notes': 'x' * 501},
      ];
      for (final body in bad) {
        final r = await call('POST', '/workout-sessions', token: tokenA, body: body);
        expect(r.status == 400 && r.errorCode == 'VALIDATION_ERROR',
            'тело $body → ${r.status} ${_short(r.body)}');
      }
    });

    await check('список — новые сверху, ?search= по заметкам', () async {
      await call('POST', '/workout-sessions',
          token: tokenA, body: session('2026-11-12', notes: 'Спина'));
      final r = await call('GET', '/workout-sessions', token: tokenA);
      expectStatus(r, 200);
      final items = r.json['items'] as List;
      expect(items.length == 2 && items.first['date'] == '2026-11-12',
          'порядок: ${items.map((e) => e['date']).toList()}');
      final s = await call('GET',
          '/workout-sessions?search=${Uri.encodeQueryComponent('РЕКОРД')}',
          token: tokenA);
      expect(s.json['total'] == 1, 'search нашёл ${s.json['total']}');
    });

    await check('сессии изолированы: B не видит и не меняет сессии A', () async {
      final list = await call('GET', '/workout-sessions', token: tokenB);
      expect(list.json['total'] == 0, 'B видит ${list.json['total']} сессий');
      expectStatus(await call('GET', '/workout-sessions/$sessionId', token: tokenB),
          404, 'NOT_FOUND');
      expectStatus(await call('DELETE', '/workout-sessions/$sessionId', token: tokenB),
          404, 'NOT_FOUND');
    });

    await check('PUT → 200, DELETE → 204 без тела, затем 404', () async {
      final u = await call('PUT', '/workout-sessions/$sessionId',
          token: tokenA, body: session('2026-11-10', duration: 60));
      expectStatus(u, 200);
      expect(u.json['durationMin'] == 60, 'PUT не применился');
      final d = await call('DELETE', '/workout-sessions/$sessionId', token: tokenA);
      expectStatus(d, 204);
      expect(d.body.isEmpty, '204 с телом');
      expectStatus(await call('GET', '/workout-sessions/$sessionId', token: tokenA),
          404, 'NOT_FOUND');
    });
  }

  // ------------------------------------------------------------------ итог
  stdout.writeln('\n${'─' * 50}');
  final color = _failed == 0 ? '\x1B[32m' : '\x1B[31m';
  stdout.writeln('${color}Пройдено: $_passed   Провалено: $_failed'
      '${_skipped > 0 ? '   Пропущено: $_skipped' : ''}\x1B[0m');
  _client.close(force: true);
  exit(_failed == 0 ? 0 : 1);
}
