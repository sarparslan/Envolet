class RegisterModel {
  final String token;
  final String name;
  final String surname;
  final String email;

  RegisterModel({
    required this.token,
    required this.name,
    required this.surname,
    required this.email,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      token: json['token'],
      name: json['user']['name'],
      surname: json['user']['surname'],
      email: json['user']['email'],
    );
  }
}
