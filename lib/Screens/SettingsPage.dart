import 'package:flutter/material.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> currencies = [
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "AUD",
    "CAD",
    "CHF",
    "CNY",
    "SEK",
    "TL"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            /// PERSONAL SECTION
            const _SectionHeader("Personal"),
            _SettingsTile(title: "Profile", onTap: () {}),
            _SettingsTile(title: "Lorem Ipsum dolor sit Amet", onTap: () {}),

            /// SHOP SECTION
            const SizedBox(height: 25),
            const _SectionHeader("Shop"),
            _SettingsTile(title: "Country", value: "Turkey", onTap: () {}),
            _SettingsTile(title: "Currency", value: "\$ USD", onTap: () {}),
            _SettingsTile(title: "Terms and Conditions", onTap: () {}),

            /// ACCOUNT SECTION
            const SizedBox(height: 25),
            const _SectionHeader("Account"),
            _SettingsTile(title: "Language", value: "English", onTap: () {}),
            ListTile(
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.white,
                activeTrackColor: Colors.blue,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
            ),

            _SettingsTile(title: "About Envolet", onTap: () {}),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Privacy Policy",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 150),
                IconButton(
                  icon: const Icon(Icons.help_outline,
                      size: 20, color: Colors.grey),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Privacy Policy"),
                          content: const Text(
                            "We respect your privacy. Your data is stored securely and never shared without your consent.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                "Close",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            /// DELETE ACCOUNT
            const SizedBox(height: 25),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: () {
                // TODO: logout
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.trash,
                color: Colors.red,
              ),
              title: const Text("Delete Account",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: delete account
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: BottomNavBarWidget(currentPage: Pages.SettingsPage),
      ),
    );
  }
}

/// Section Title
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Single Row Item
class _SettingsTile extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}
