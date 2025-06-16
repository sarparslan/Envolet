import 'dart:ui';

import 'package:envolet_frontend/screens/home_page.dart';
import 'package:envolet_frontend/screens/settings_page.dart';
import 'package:envolet_frontend/screens/tracker_page.dart';
import 'package:envolet_frontend/screens/transaction_page.dart';
import 'package:envolet_frontend/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Pages { home, tracker, transaction, settings }

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({required this.currentPage, super.key});

  final Pages currentPage;

  static const _activeColor = Colors.blue;
  static const _iconColor = Colors.black;
  static const _iconSize = 22.0;

  static Widget _pageFor(Pages page) => switch (page) {
        Pages.home => const HomePage(),
        Pages.tracker => const TrackerPage(),
        Pages.transaction => const TransactionPage(),
        Pages.settings => const SettingsPage(),
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navItem(context, FontAwesomeIcons.house, 'Home', Pages.home),
                  _navItem(context, FontAwesomeIcons.chartColumn, 'Insights',
                      Pages.tracker),
                  _navItem(context, FontAwesomeIcons.moneyBillTransfer,
                      'Transactions', Pages.transaction),
                  _navItem(context, FontAwesomeIcons.gear, 'Settings',
                      Pages.settings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    FaIconData icon,
    String label,
    Pages page,
  ) {
    final isSelected = currentPage == page;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSelected) return;
          // Replace instead of push so tab switches don't grow the stack.
          Navigator.of(context).pushReplacement(fadeRoute(_pageFor(page)));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 20 : 0,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: _activeColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            FaIcon(
              icon,
              size: _iconSize,
              color: isSelected ? _activeColor : _iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
