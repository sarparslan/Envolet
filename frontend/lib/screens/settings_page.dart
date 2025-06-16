import 'package:envolet_frontend/core/constants.dart';
import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/widgets/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showCurrencyPicker() {
    final settings = context.read<SettingsProvider>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: Colors.white,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 36,
          scrollController: FixedExtentScrollController(
            initialItem: currencies.indexOf(settings.currency),
          ),
          onSelectedItemChanged: (index) =>
              settings.setCurrency(currencies[index]),
          children: currencies.map((c) => Center(child: Text(c))).toList(),
        ),
      ),
    );
  }

  void _showInfoDialog(String title) {
    String content;
    final colorSet = {
      "textColor": Colors.black,
      "backgroundColor": Colors.white,
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
                fontSize: 20)),
        content: Text(content,
            style: TextStyle(
                color: colorSet["textColor"], height: 1.5, fontSize: 16)),
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
    final user = context.watch<SessionProvider>().user;
    final currency = context.watch<SettingsProvider>().currency;
    final dividerColor = Colors.grey.shade300;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _SectionHeader("Account Info", Colors.black),
            _SettingsTileNoArrow(
                title: "Name",
                value: user?.fullName ?? '',
                textColor: Colors.black),
            _SettingsTileNoArrow(
                title: "Email",
                value: user?.email ?? '',
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
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(currency,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.black),
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
      bottomNavigationBar:
          const BottomNavBarWidget(currentPage: Pages.settings),
    );
  }

  Widget logOut() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.black),
      title: Text("Log Out", style: TextStyle(color: Colors.black)),
      onTap: () => AppDialogs.showLogoutDialog(context),
    );
  }

  Widget deleteAccount() {
    return ListTile(
      leading: const Icon(Icons.delete_outline, color: Colors.red),
      title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
      onTap: () => AppDialogs.showDeleteAccountDialog(context),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: color)),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: Text(value, style: TextStyle(fontSize: 16, color: textColor)),
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
