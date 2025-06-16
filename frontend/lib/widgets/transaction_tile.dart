import 'package:envolet_frontend/core/constants.dart';
import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.trailing});

  final Transaction transaction;

  /// Optional widget shown after the amount, e.g. an actions button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currency;
    final icon = categoryIcons[transaction.category] ?? FontAwesomeIcons.tag;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: FaIcon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM').format(transaction.date),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            formatAmount(transaction.amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          FaIcon(
            currencyIcons[currency] ?? FontAwesomeIcons.moneyBillWave,
            size: 16,
            color: Colors.black87,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
