import 'dart:convert';

import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _authBody = {
  'token': 'jwt-token',
  'user': {'name': 'Jane', 'surname': 'Doe', 'email': 'jane@example.com'},
};

void main() {
  late InMemoryTokenStorage tokens;
  late List<http.Request> requests;

  ApiService buildApi(http.Response Function(http.Request) handler) {
    return ApiService(
      tokenStorage: tokens,
      baseUrl: 'http://api.test',
      client: MockClient((request) async {
        requests.add(request);
        return handler(request);
      }),
    );
  }

  http.Response json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status,
          headers: {'content-type': 'application/json; charset=utf-8'});

  setUp(() {
    tokens = InMemoryTokenStorage();
    requests = [];
  });

  test('login stores the returned token', () async {
    final api = buildApi((_) => json(_authBody));

    final session = await api.login(email: 'jane@example.com', password: 'pw');

    expect(session.user.fullName, 'Jane Doe');
    expect(await tokens.read(), 'jwt-token');
    expect(requests.single.url.path, '/auth/login');
    expect(requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('authenticated requests send the bearer token', () async {
    await tokens.write('abc');
    final api = buildApi((_) => json({'data': []}));

    await api.getTransactions();

    expect(requests.single.headers['Authorization'], 'Bearer abc');
  });

  test('requests without a stored token fail fast with 401', () async {
    final api = buildApi((_) => json({}));

    expect(
      api.getAssets(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
    expect(requests, isEmpty);
  });

  test('query parameters are URL-encoded', () async {
    await tokens.write('abc');
    final api = buildApi((_) => json({
          'buckets': [1, 2, 3, 4, 5]
        }));

    final buckets =
        await api.getMonthBuckets('2025-06', category: 'Food & Drinks');

    expect(buckets, [1.0, 2.0, 3.0, 4.0, 5.0]);
    expect(requests.single.url.queryParameters, {
      'category': 'Food & Drinks',
      'month': '2025-06',
    });
  });

  test('transactions are parsed and sorted newest first', () async {
    await tokens.write('abc');
    final api = buildApi((_) => json({
          'data': [
            {
              '_id': '1',
              'amount': 10,
              'category': 'Bills',
              'date': '2025-05-01'
            },
            {
              '_id': '2',
              'amount': 5.5,
              'category': 'Travel',
              'date': '2025-06-01'
            },
          ],
        }));

    final transactions = await api.getTransactions();

    expect(transactions.map((t) => t.id), ['2', '1']);
    expect(transactions.first.amount, 5.5);
  });

  test('error responses surface the server detail', () async {
    await tokens.write('abc');
    final api = buildApi((_) => json({'detail': 'Transaction not found'}, 404));

    expect(
      api.deleteTransaction('missing'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'status', 404)
          .having((e) => e.message, 'message', 'Transaction not found')),
    );
  });

  test('network failures are wrapped in ApiException', () async {
    await tokens.write('abc');
    final api = ApiService(
      tokenStorage: tokens,
      baseUrl: 'http://api.test',
      client: MockClient((_) => throw http.ClientException('offline')),
    );

    expect(api.getAssets(), throwsA(isA<ApiException>()));
  });

  test('deleteAccount clears the stored token', () async {
    await tokens.write('abc');
    final api = buildApi((_) => json({'message': 'deleted'}));

    await api.deleteAccount();

    expect(requests.single.method, 'DELETE');
    expect(await tokens.read(), isNull);
  });
}
