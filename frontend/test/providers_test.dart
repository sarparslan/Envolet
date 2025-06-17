import 'dart:convert';

import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SessionProvider', () {
    test('splitFullName keeps multi-part first names together', () {
      expect(SessionProvider.splitFullName('Jane Mary  Doe'),
          ('Jane Mary', 'Doe'));
      expect(SessionProvider.splitFullName(' Jane '), ('Jane', ''));
    });

    test('restoreSession clears an expired token', () async {
      final tokens = InMemoryTokenStorage();
      await tokens.write('expired');
      final api = ApiService(
        tokenStorage: tokens,
        baseUrl: 'http://api.test',
        client: MockClient((_) async =>
            http.Response(jsonEncode({'detail': 'Invalid token'}), 401)),
      );

      final restored = await SessionProvider(api).restoreSession();

      expect(restored, isFalse);
      expect(await tokens.read(), isNull);
    });

    test('register sends the split name and exposes the user', () async {
      late Map<String, dynamic> sentBody;
      final api = ApiService(
        tokenStorage: InMemoryTokenStorage(),
        baseUrl: 'http://api.test',
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'token': 't',
              'user': {'name': 'Jane', 'surname': 'Doe', 'email': 'j@x.io'},
            }),
            201,
          );
        }),
      );
      final session = SessionProvider(api);

      await session.register(
        fullName: 'Jane Doe',
        email: 'j@x.io',
        password: 'secret1',
      );

      expect(sentBody['name'], 'Jane');
      expect(sentBody['surname'], 'Doe');
      expect(session.user?.email, 'j@x.io');
    });
  });

  group('SettingsProvider', () {
    test('defaults to USD and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsProvider(prefs);

      expect(settings.currency, 'USD');

      await settings.setCurrency('EUR');

      expect(settings.currencySymbol, '€');
      expect(SettingsProvider(prefs).currency, 'EUR');
    });
  });
}
