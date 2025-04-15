import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // NumberFormat için

class CustomCreditCard extends StatelessWidget {
  final String cardTail; // Last 4 digits
  final String bankName;
  final String balance;
  final VoidCallback onEditPressed;
  final String? colorHex; // Optional card color (hex)
  final String? cardBrand;
  final String? currency;

  const CustomCreditCard({
    Key? key,
    required this.cardTail,
    required this.bankName,
    required this.balance,
    required this.onEditPressed,
    this.colorHex,
    this.cardBrand,
    this.currency,
  }) : super(key: key);

  // Convert a hex string to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF" + hex;
    return Color(int.parse(hex, radix: 16));
  }

  // Get icon based on cardBrand
  IconData? _getCardIcon(String? brand) {
    switch (brand) {
      case "Visa":
        return FontAwesomeIcons.ccVisa;
      case "MasterCard":
        return FontAwesomeIcons.ccMastercard;
      case "American Express":
        return FontAwesomeIcons.ccAmex;
      case "Discover":
        return FontAwesomeIcons.ccDiscover;
      case "Amazon Pay":
        return FontAwesomeIcons.ccAmazonPay;
      case "Apple Pay":
        return FontAwesomeIcons.ccApplePay;
      case "Paypal":
        return FontAwesomeIcons.ccPaypal;
      default:
        return null;
    }
  }

  // Get currency symbol based on currency code
  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      case "JPY":
        return "¥";
      case "AUD":
        return "A\$";
      case "CAD":
        return "C\$";
      case "CHF":
        return "CHF";
      case "CNY":
        return "¥";
      case "SEK":
        return "kr";
      case "TL":
        return "₺";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        (colorHex != null) ? _hexToColor(colorHex!) : Colors.black87;
    final icon = _getCardIcon(cardBrand);
    final currencySymbol =
        (currency != null) ? _getCurrencySymbol(currency!) : "\$";

    // Format the balance with thousand separators
    String formattedBalance = balance;
    try {
      final num value = num.parse(balance);
      formattedBalance = NumberFormat('#,##0').format(value);
    } catch (e) {
      // Eğer parse edilemezse, orijinal değeri kullanın
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Card brand icon and "**** {cardTail}"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon != null
                  ? Icon(icon, color: Colors.white, size: 30)
                  : SizedBox(width: 30, height: 30),
              Text(
                '**** $cardTail',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 65),
          // Bank name
          Text(
            bankName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          // Bottom row: Balance and Edit button, with currency symbol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currencySymbol$formattedBalance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: onEditPressed,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
