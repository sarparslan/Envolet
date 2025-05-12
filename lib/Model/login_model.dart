class LoginModel {
  final bool success;
  final String token;

  LoginModel({
    required this.success,
    required this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json["success"],
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "token": token,
    };
  }
}
