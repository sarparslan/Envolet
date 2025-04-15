import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:envolet_frontend/Widgets/investAndGrow_popup.dart';
import 'package:envolet_frontend/Widgets/transfer_popup.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Text(
                  "Search Page", ////TODO : Get Username from API or SharedPreferences
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TransferPopup(
                      transferAmount: '\$25.00',
                      transferTo: 'Sarp Arslan',
                      status: 'Success',
                      date: '20 May, 2024, 12:32 AM',
                      category: 'Food',
                      nominal: '\$25.00',
                      fee: 'Free',
                    );
                  },
                );
              },
              child: Text('Show Transfer Popup'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return InvestAndGrowPopup();
                  },
                );
              },
              child: Text('Show Invest Popup'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: BottomNavBarWidget(currentPage: Pages.SearchPage),
      ),
    );
  }
}
