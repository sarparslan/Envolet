import 'dart:ui';
import 'dart:io';
import 'package:envolet_frontend/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:envolet_frontend/screens/settings_page.dart';
import 'package:envolet_frontend/screens/transaction_page.dart';
import 'package:envolet_frontend/screens/tracker_page.dart';

enum Pages {
  settings,
  transaction,
  tracker,
  home,
}

class BottomNavBarWidget extends StatelessWidget {
  final Pages currentPage;

  const BottomNavBarWidget({required this.currentPage, super.key});

  @override
  Widget build(BuildContext context) {
    final navColors = {
      "backgroundColor": Colors.white.withValues(alpha: 0.2),
      "borderColor": Colors.white.withValues(alpha: 0.3),
      "iconColor": Colors.black,
      "activeColor": Colors.blue,
    };

    double height = MediaQuery.of(context).size.height;
    double aspectRatio = height / MediaQuery.of(context).size.width;
    double scalingFactor =
        (Platform.isIOS && aspectRatio < 1.5) ? 0.016 : 0.023;
    double iconSize = height * scalingFactor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height * 0.09,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: navColors["backgroundColor"],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: navColors["borderColor"]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                  Icons.home, "Home", Pages.home, iconSize, context, navColors),
              _buildNavItem(Icons.bar_chart, "Insights", Pages.tracker,
                  iconSize, context, navColors),
              _buildNavItem(FontAwesomeIcons.moneyBillTransfer, "Transaction",
                  Pages.transaction, iconSize, context, navColors),
              _buildNavItem(FontAwesomeIcons.gear, "Settings", Pages.settings,
                  iconSize, context, navColors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Pages page, double iconSize,
      BuildContext context, Map<String, Color> navColors) {
    bool isSelected = currentPage == page;
    return GestureDetector(
      onTap: () {
        if (currentPage != page) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              switch (page) {
                case Pages.home:
                  return HomePage();
                case Pages.tracker:
                  return TrackerPage();

                case Pages.transaction:
                  return TransactionPage();
                case Pages.settings:
                  return SettingsPage();
              }
            },
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 3,
            width: isSelected ? 20 : 0,
            decoration: BoxDecoration(
              color: navColors["activeColor"],
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.only(bottom: 3),
          ),
          Icon(icon,
              size: iconSize,
              color: isSelected
                  ? navColors["activeColor"]
                  : navColors["iconColor"]),
        ],
      ),
    );
  }
}
