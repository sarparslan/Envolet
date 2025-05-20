class LoginModel {
  final String token;
  final String name;
  final String surname;
  final String email;

  LoginModel({
    required this.token,
    required this.name,
    required this.surname,
    required this.email,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'],
      name: json['user']['name'],
      surname: json['user']['surname'],
      email: json['user']['email'],
    );
  }
}
