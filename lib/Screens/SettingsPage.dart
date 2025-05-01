import 'package:envolet_frontend/Util/globals.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedCurrency = 'EUR';
  String selectedLanguage = 'EN';
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
  final List<String> languages = ['EN', 'TR'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 30),
        child: ListView(
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Account Info",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Name Surname",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("example@mail.com",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text("App Preferences",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Currency"),
              trailing: DropdownButton<String>(
                value: selectedCurrency,
                items: currencies
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
            ),
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
            const Divider(height: 40),
            const Text("About App",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text("Version Information",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(width: 120),
                Text("1.0",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
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
            const SizedBox(height: 10),
            const Divider(height: 40),
            const Text("Account Actions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
