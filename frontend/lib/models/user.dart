class User {
  const User({
    required this.name,
    required this.surname,
    required this.email,
  });

  final String name;
  final String surname;
  final String email;

  String get fullName => '$name $surname'.trim();

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String? ?? '',
        surname: json['surname'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}

/// Response returned by the login and register endpoints.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
