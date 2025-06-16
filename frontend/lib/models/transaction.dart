import 'package:intl/intl.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final double amount;
  final String category;
  final DateTime date;

  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  /// Request body used when creating or updating a transaction.
  static Map<String, dynamic> toRequestJson({
    required double amount,
    required String category,
    required DateTime date,
  }) =>
      {
        'amount': amount,
        'category': category,
        'date': _apiDateFormat.format(date),
      };
}
