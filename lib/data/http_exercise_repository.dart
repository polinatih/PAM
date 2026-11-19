import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'exercise.dart';
import 'exercise_repository.dart';
import 'result.dart';
import 'token_store.dart';

/// http-реализация хранилища упражнений (GET /exercises, GET /exercises/{id}).
class HttpExerciseRepository implements ExerciseRepository {
  HttpExerciseRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized; // 401 → решает корень

  static const _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await tokens.read() ?? ''}',
      };

  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  Future<Result<T>> _guard<T>(Future<Result<T>> Function() request) async {
    try {
      return await request();
    } on SocketException {
      return Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return Err('Нет связи с сервером');
    } on TimeoutException {
      return Err('Сервер не отвечает');
    } on FormatException {
      return Err('Ответ не тот, что обещан');
    } on TypeError {
      return Err('Ответ не тот, что обещан');
    }
  }

  @override
  Future<Result<List<Exercise>>> fetchAll() => _guard(() async {
        final res = await http
            .get(Uri.parse('$baseUrl/exercises?limit=100'),
                headers: await _headers())
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res));
        final data = jsonDecode(res.body) as Map<String, dynamic>; // конверт
        return Ok((data['items'] as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList());
      });

  @override
  Future<Result<Exercise>> fetchById(int id) => _guard(() async {
        final res = await http
            .get(Uri.parse('$baseUrl/exercises/$id'), headers: await _headers())
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res)); // 404 → Err
        return Ok(
            Exercise.fromJson(jsonDecode(res.body) as Map<String, dynamic>));
      });
}
