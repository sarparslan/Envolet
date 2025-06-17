import 'package:envolet_frontend/models/asset.dart';
import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthSession parses token and user', () {
    final session = AuthSession.fromJson({
      'token': 'abc123',
      'user': {'name': 'Jane', 'surname': 'Doe', 'email': 'jane@example.com'},
    });

    expect(session.token, 'abc123');
    expect(session.user.fullName, 'Jane Doe');
  });

  test('Transaction round-trips the API date format', () {
    final transaction = Transaction.fromJson({
      '_id': 't1',
      'amount': 42,
      'category': 'Bills',
      'date': '2025-06-09',
    });

    expect(transaction.amount, 42.0);
    expect(transaction.date, DateTime(2025, 6, 9));
    expect(
      Transaction.toRequestJson(
        amount: transaction.amount,
        category: transaction.category,
        date: transaction.date,
      ),
      {'amount': 42.0, 'category': 'Bills', 'date': '2025-06-09'},
    );
  });

  test('Asset tolerates missing optional fields', () {
    final asset = Asset.fromJson({'_id': 'a1', 'amount': 1500});

    expect(asset.amount, 1500);
    expect(asset.bankName, '');
  });
}
