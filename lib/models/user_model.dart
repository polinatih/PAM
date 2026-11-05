import 'package:flutter/foundation.dart';

import '../data/user.dart';

/// Разделяемое состояние: кто сейчас вошёл в приложение.
/// Пишет его экран входа, читает профиль — два экрана, переживает навигацию,
/// поэтому это Provider, а не setState.
/// На L4 пользователь берётся из формы входа (локальная валидация L3),
/// на L5 — из ответа POST /auth/login.
class UserModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isSignedIn => _user != null;

  void signIn(User user) {
    _user = user;
    notifyListeners(); // профиль узнаёт нового пользователя
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
