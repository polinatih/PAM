import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';
import 'user.dart';

/// register / login / me по контракту бэкенда; token уходит в TokenStore.
/// Каждый запрос — три слоя отказа (C8):
///   1) дорога упала        → исключение, ловится по конкретному типу;
///   2) сервер сказал «нет» → читаем statusCode, переводим конверт;
///   3) тело не по контракту → FormatException / TypeError при разборе.
class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;
  static const _timeout = Duration(seconds: 8);

  Future<Result<User>> register(String email, String password, String name) =>
      _post('/auth/register',
          {'email': email, 'password': password, 'name': name});

  Future<Result<User>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<void> logout() => tokens.clear();

  /// GET /me — кто владелец сохранённого token-а (при запуске приложения).
  Future<Result<User>> me() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {'Authorization': 'Bearer ${await tokens.read() ?? ''}'},
      ).timeout(_timeout);
      if (res.statusCode != 200) return Err(apiMessage(res)); // слой 2
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(User.fromJson(data));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет связи с сервером');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }

  Future<Result<User>> _post(String path, Map<String, Object?> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode != 200 && res.statusCode != 201) {
        // слой 2: 400 / 401 / 409 — из конверта ошибки
        return Err(apiMessage(res, isLogin: path == '/auth/login'));
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await tokens.save(data['token'] as String); // C9: setString
      return Ok(User.fromJson(data['user'] as Map<String, dynamic>));
    } on SocketException {
      return const Err('Нет сети — повторите попытку'); // слой 1
    } on http.ClientException {
      return const Err('Нет связи с сервером');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан'); // слой 3
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
