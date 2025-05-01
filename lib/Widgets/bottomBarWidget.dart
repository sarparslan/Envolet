import 'dart:ui'; // Bulanıklık efekti için gerekli
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:envolet_frontend/Screens/HomePage.dart';
import 'package:envolet_frontend/Screens/SettingsPage.dart';
import 'package:envolet_frontend/Screens/TransactionPage.dart';
import 'package:envolet_frontend/Screens/AssetsPage.dart';
import 'package:envolet_frontend/Screens/InsightsPage.dart'; // InsightsPage import edildi

enum Pages {
  HomePage,
  SettingsPage,
  TransactionPage,
  InsightsPage, // Enum'a eklendi
  AssetsPage,
}

class BottomNavBarWidget extends StatelessWidget {
  final Pages currentPage;

  BottomNavBarWidget({required this.currentPage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                  Icons.home, "Home", Pages.HomePage, iconSize, context),
              _buildNavItem(FontAwesomeIcons.moneyBillTransfer, "Transaction",
                  Pages.TransactionPage, iconSize, context),
              _buildNavItem(Icons.bar_chart, "Insights", Pages.InsightsPage,
                  iconSize, context), // Yeni öğe
              _buildNavItem(
                  Icons.wallet, "Assets", Pages.AssetsPage, iconSize, context),
              _buildNavItem(FontAwesomeIcons.gear, "Settings",
                  Pages.SettingsPage, iconSize, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Pages page, double iconSize,
      BuildContext context) {
    bool isSelected = currentPage == page;
    return GestureDetector(
      onTap: () {
        if (currentPage != page) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              switch (page) {
                case Pages.HomePage:
                  return HomePage();
                case Pages.TransactionPage:
                  return TransactionPage();
                case Pages.InsightsPage:
                  return InsightsPage(); // Yeni case
                case Pages.AssetsPage:
                  return AssetsPage();
                case Pages.SettingsPage:
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.only(bottom: 3),
          ),
          Icon(icon,
              size: iconSize, color: isSelected ? Colors.blue : Colors.black),
        ],
      ),
    );
  }
}
