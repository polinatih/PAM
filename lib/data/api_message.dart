import 'dart:convert';

import 'package:http/http.dart' as http;

/// Переводит конверт ошибки бэкенда {"error": {"code", "message"}}
/// в русское сообщение для человека — в одном месте.
/// Английский message сервера на экран не попадает: стабилен только code.
/// [isLogin]: при входе UNAUTHORIZED значит «неверный пароль», а не
/// «истекла сессия».
String apiMessage(http.Response res, {bool isLogin = false}) {
  try {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final error = body['error'] as Map<String, dynamic>;
    final code = error['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' =>
        isLogin ? 'Неверный email или пароль' : 'Сессия истекла — войдите снова',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    // тело — не JSON (например, HTML от прокси)
    return 'Ошибка сервера (${res.statusCode})';
  } on TypeError {
    // JSON, но не по контракту
    return 'Ошибка сервера (${res.statusCode})';
  }
}
