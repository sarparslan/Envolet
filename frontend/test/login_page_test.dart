import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/screens/auth/login_page.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows a hint when submitting an empty form', (tester) async {
    var requestCount = 0;
    final api = ApiService(
      tokenStorage: InMemoryTokenStorage(),
      baseUrl: 'http://api.test',
      client: MockClient((_) async {
        requestCount++;
        return http.Response('{}', 200);
      }),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessionProvider(api),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter both email and password'), findsOneWidget);
    expect(requestCount, 0);
  });
}
