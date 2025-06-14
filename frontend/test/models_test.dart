import 'package:envolet_frontend/models/login_model.dart';
import 'package:envolet_frontend/models/register_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'token': 'abc123',
    'user': {
      'name': 'Jane',
      'surname': 'Doe',
      'email': 'jane@example.com',
    },
  };

  test('LoginModel parses the auth response', () {
    final model = LoginModel.fromJson(json);

    expect(model.token, 'abc123');
    expect(model.name, 'Jane');
    expect(model.surname, 'Doe');
    expect(model.email, 'jane@example.com');
  });

  test('RegisterModel parses the auth response', () {
    final model = RegisterModel.fromJson(json);

    expect(model.token, 'abc123');
    expect(model.email, 'jane@example.com');
  });
}
