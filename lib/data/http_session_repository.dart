import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'session_repository.dart';
import 'token_store.dart';
import 'workout_session.dart';

/// Вторая реализация интерфейса L4 — на http, против своего бэкенда.
/// Интерфейс SessionRepository не изменился ни на символ.
class HttpSessionRepository implements SessionRepository {
  HttpSessionRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;

  /// Что делать при 401 — решает корень композиции (назад на login);
  /// репозиторий не импортирует router.
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Uri _uri(String path) => Uri.parse('$baseUrl/workout-sessions$path');

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await tokens.read() ?? ''}', // C8: Bearer
      };

  /// 401 = пропуск умер: token выбрасывается (C9), корень навигирует.
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  /// Слои 1 и 3 (C8) — одинаковы для всех методов: ветки по конкретным
  /// типам исключений, каждая — в своё сообщение.
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() request) async {
    try {
      return await request();
    } on SocketException {
      return Err('Нет сети — повторите попытку'); // дорога упала
    } on http.ClientException {
      return Err('Нет связи с сервером');
    } on TimeoutException {
      return Err('Сервер не отвечает'); // поэтому .timeout на каждом запросе
    } on FormatException {
      return Err('Ответ не тот, что обещан'); // тело — не JSON
    } on TypeError {
      return Err('Ответ не тот, что обещан'); // JSON, но не по контракту
    }
  }

  @override
  Future<Result<List<WorkoutSession>>> fetchAll() => _guard(() async {
        final res = await http
            .get(_uri('?limit=100'), headers: await _headers())
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res)); // слой 2
        final data = jsonDecode(res.body) as Map<String, dynamic>; // конверт!
        return Ok((data['items'] as List)
            .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
            .toList());
      });

  @override
  Future<Result<WorkoutSession>> fetchById(int id) => _guard(() async {
        final res = await http
            .get(_uri('/$id'), headers: await _headers())
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res)); // 404 → Err
        return Ok(WorkoutSession.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>));
      });

  @override
  Future<Result<WorkoutSession>> create(WorkoutSession session) =>
      _guard(() async {
        final res = await http
            .post(_uri(''),
                headers: await _headers(),
                body: jsonEncode(session.toJson()))
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 201) return Err(apiMessage(res)); // 201 — создано
        // id и userId пришли от сервера
        return Ok(WorkoutSession.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>));
      });

  @override
  Future<Result<WorkoutSession>> update(WorkoutSession session) =>
      _guard(() async {
        final res = await http
            .put(_uri('/${session.id}'),
                headers: await _headers(),
                body: jsonEncode(session.toJson()))
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res));
        return Ok(WorkoutSession.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>));
      });

  @override
  Future<Result<void>> delete(int id) => _guard(() async {
        final res = await http
            .delete(_uri('/$id'), headers: await _headers())
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 204) return Err(apiMessage(res));
        return const Ok(null); // 204: тело пустое — jsonDecode НЕ вызываем
      });
}
