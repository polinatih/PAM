// Доменная модель (L4): живёт отдельно от mock-данных — на L5 mock умирает,
// а модель переходит дальше. Поля = ответ POST /auth/login и GET /me.

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
