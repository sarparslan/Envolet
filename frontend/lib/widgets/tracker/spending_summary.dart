import 'package:envolet_frontend/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A colored legend label with a formatted amount underneath.
class SpendingSummaryItem extends StatelessWidget {
  const SpendingSummaryItem({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyIcon,
  });

  final String label;
  final double amount;
  final Color color;
  final FaIconData currencyIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              formatAmount(amount.round()),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            FaIcon(currencyIcon, size: 16),
          ],
        ),
      ],
    );
  }
}
