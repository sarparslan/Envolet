import 'package:envolet_frontend/models/asset.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CreditCard extends StatelessWidget {
  const CreditCard({super.key, required this.asset, required this.onEdit});

  final Asset asset;
  final VoidCallback onEdit;

  static const Map<String, FaIconData> _brandIcons = {
    'Visa': FontAwesomeIcons.ccVisa,
    'MasterCard': FontAwesomeIcons.ccMastercard,
    'American Express': FontAwesomeIcons.ccAmex,
    'Discover': FontAwesomeIcons.ccDiscover,
    'Amazon Pay': FontAwesomeIcons.ccAmazonPay,
    'Apple Pay': FontAwesomeIcons.ccApplePay,
    'Paypal': FontAwesomeIcons.ccPaypal,
  };

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final brandIcon = _brandIcons[asset.brand];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: colorFromHex(asset.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              brandIcon != null
                  ? FaIcon(brandIcon, color: Colors.white, size: 30)
                  : const SizedBox.square(dimension: 30),
              Text(
                '**** ${asset.lastFourDigits}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            asset.bankName,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$currencySymbol${formatAmount(asset.amount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child:
                    const Text('Edit', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
