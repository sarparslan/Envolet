import 'package:envolet_frontend/Auth/login.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/Helper/helper.dart';
import 'package:envolet_frontend/Util/alart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userEmail;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    final user = await Api.getMe();
    if (user != null && mounted) {
      setState(() {
        userEmail = user['email'];
        userName = user['name'] + " " + user['surname'];
      });
    }
  }

  final List<String> currencies = [
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "TL"
        "CHF",
    "SEK",
  ];

  String selectedCurrency = globalCurrency;

  void _showCurrencyPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        color: Colors.white,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: MediaQuery.of(context).size.height * 0.04,
          scrollController: FixedExtentScrollController(
              initialItem: currencies.indexOf(selectedCurrency)),
          onSelectedItemChanged: (index) {
            setState(() {
              selectedCurrency = currencies[index];
              globalCurrency = currencies[index];
            });
          },
          children: currencies.map((e) => Text(e)).toList(),
        ),
      ),
    );
  }

  void _showInfoDialog(String title) {
    String content;
    final colorSet = {
      "textColor": isDarkMode ? Colors.white : Colors.black,
      "backgroundColor": isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
    };

    switch (title) {
      case "About Envolet":
        content =
            "Envolet is your all-in-one financial companion. From budgeting to smart investments, we help you manage your money with simplicity and style.";
        break;
      case "Terms and Conditions":
        content =
            "By using Envolet, you agree to our terms: Use responsibly, respect others, and know that we never sell your data. Full terms are available on our website.";
        break;
      case "Privacy Policy":
        content =
            "Your privacy is sacred. We encrypt your data and never share it with third parties without your consent. You’re in control.";
        break;
      default:
        content = "";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorSet["backgroundColor"],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: TextStyle(
                color: colorSet["textColor"],
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.025)),
        content: Text(content,
            style: TextStyle(
                color: colorSet["textColor"],
                height: 1.5,
                fontSize: MediaQuery.of(context).size.height * 0.02)),
        actions: [
          TextButton(
            child: const Text("Close", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final bgColor =
        isDarkMode ? const Color.fromARGB(26, 15, 13, 13) : Colors.white;
    final dividerColor = isDarkMode ? Colors.white : Colors.grey.shade300;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.only(top: height * 0.005),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.03),
          children: [
            _SectionHeader("Account Info", Colors.black),
            _SettingsTileNoArrow(
                title: "Name",
                value: userName ?? "loading...",
                textColor: Colors.black),
            _SettingsTileNoArrow(
                title: "Email",
                value: userEmail ?? "loading...",
                textColor: Colors.black),
            Divider(color: dividerColor),
            _SectionHeader("App Preferences", Colors.black),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Currency", style: TextStyle(color: Colors.black)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.02),
                    child: Text(selectedCurrency,
                        style: TextStyle(
                            fontSize: height * 0.02, color: Colors.black)),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: height * 0.018, color: Colors.black),
                ],
              ),
              onTap: _showCurrencyPicker,
            ),
            Divider(color: dividerColor),
            _SectionHeader("About", Colors.black),
            _InfoTileWithIcon(
                title: "About Envolet",
                onPressed: () => _showInfoDialog("About Envolet"),
                textColor: Colors.black),
            _InfoTileWithIcon(
                title: "Terms and Conditions",
                onPressed: () => _showInfoDialog("Terms and Conditions"),
                textColor: Colors.black),
            _InfoTileWithIcon(
                title: "Privacy Policy",
                onPressed: () => _showInfoDialog("Privacy Policy"),
                textColor: Colors.black),
            Divider(color: dividerColor),
            logOut(),
            deleteAccount()
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: BottomNavBarWidget(currentPage: Pages.SettingsPage),
      ),
    );
  }

  Widget logOut() {
    return ListTile(
      leading:
          Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.black),
      title: Text("Log Out",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      onTap: () => Util.showLogoutDialog(context),
    );
  }

  Widget deleteAccount() {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: Colors.red),
      title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
      onTap: () => Util.showDeleteAccountDialog(context),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.015),
      child: Text(title,
          style: TextStyle(
              fontSize: height * 0.022,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}

class _SettingsTileNoArrow extends StatelessWidget {
  final String title;
  final String value;
  final Color textColor;

  const _SettingsTileNoArrow(
      {required this.title, required this.value, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: TextStyle(fontSize: height * 0.02, color: textColor)),
      trailing: Text(value,
          style: TextStyle(fontSize: height * 0.02, color: textColor)),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color textColor;

  const _SettingsSwitchTile(
      {required this.title,
      required this.value,
      required this.onChanged,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.blue,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey,
      ),
    );
  }
}

class _InfoTileWithIcon extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  const _InfoTileWithIcon(
      {required this.title, required this.onPressed, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.grey),
        onPressed: onPressed,
      ),
    );
  }
}
