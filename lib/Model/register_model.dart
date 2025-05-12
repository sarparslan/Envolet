class RegisterModel {
  final bool success;
  final String token;

  RegisterModel({
    required this.success,
    required this.token,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
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
