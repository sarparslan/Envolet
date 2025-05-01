import 'package:envolet_frontend/Util/Widgets/CreditCard.dart';
import 'package:envolet_frontend/Widgets/CardAdditionWidget.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dotted_border/dotted_border.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> cards = [];

  void searchButtonPressed() {
    print("searchButtonPressed");
  }

  void revenueButtonPressed() {
    print("revenueButtonPressed");
  }

  void expensebuttonPressed() {
    print("expensebuttonPressed");
  }

  void allAcountsButtonPressed() {
    print("allAcountsButtonPressed");
  }

  void otherButtonPressed() {
    print("otherButtonPressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 60, left: 20, bottom: 15),
              child: title(),
            ),
            cardRow(),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: selectionRow(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Row(
                children: [
                  Text(
                    'Latest Payments',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: latestPaymentsRow(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: BottomNavBarWidget(currentPage: Pages.HomePage),
      ),
    );
  }

  Widget title() {
    return Row(
      children: [
        Text(
          "Welcome, Sarp.", ////TODO : Get Username from API or SharedPreferences
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget selectionRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildButtonColumn(
              Icons.arrow_upward, "Revenue", revenueButtonPressed),
          _buildButtonColumn(
              Icons.arrow_downward, "Expense", expensebuttonPressed),
          _buildButtonColumn(Icons.account_balance_wallet, "All Accounts",
              allAcountsButtonPressed),
          _buildButtonColumn(Icons.more_horiz, "Other", otherButtonPressed),
        ],
      ),
    );
  }

  Column _buildButtonColumn(IconData icon, String label, VoidCallback func) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: func,
              icon: Icon(icon, size: 24),
            )),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget latestPaymentsRow() {
    return Container(
      height: 200,
      width: 350,
      color: Colors.grey[100],
      child: Column(
        children: [
          paymentDetailRow('images/netflix_logo.jpg', 'Netflix',
              '21 Sept - 13:01', '\$19.00'),
          paymentDetailRow('images/macys_logo.jpg', 'Shopping',
              '20 Sept - 18:43', '\$65.99'),
        ],
      ),
    );
  }

  Widget paymentDetailRow(
      String logoPath, String description, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            logoPath,
            width: 50,
            height: 30,
          ), // Logo
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(date),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget cardRow() {
    return Column(
      children: [
        Container(
          height: 240,
          width: 600,
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length + 1,
            itemBuilder: (context, index) {
              if (index == cards.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: InkWell(
                    onTap: () async {
                      final newCard = await showDialog<Map<String, String>>(
                        context: context,
                        builder: (context) => CardAdditionDialog(),
                      );
                      if (newCard != null) {
                        setState(() {
                          cards.add(newCard);
                        });
                      }
                    },
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(12),
                      padding: EdgeInsets.all(6),
                      color: Colors.grey,
                      dashPattern: [8, 4],
                      strokeWidth: 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 48, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Tap to add a new card",
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                var card = cards[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: CustomCreditCard(
                    cardTail: card['cardTail']!,
                    bankName: card['bankName']!,
                    balance: card['balance']!,
                    colorHex: card['color'],
                    cardBrand: card['cardBrand'],
                    currency: card['currency'],
                    onEditPressed: () async {
                      final result = await showDialog<Map<String, String>>(
                        context: context,
                        builder: (context) =>
                            CardAdditionDialog(initialData: card),
                      );

                      if (result != null) {
                        // 1) Silme işlemi mi döndü?
                        if (result['delete'] == 'true') {
                          // Geri dönen 'cardNumber' ile eşleşen kartı listeden çıkar.
                          setState(() {
                            cards.removeWhere(
                                (c) => c['cardNumber'] == result['cardNumber']);
                          });
                        } else {
                          final existingIndex = cards.indexWhere(
                            (c) => c['cardNumber'] == result['cardNumber'],
                          );

                          setState(() {
                            if (existingIndex != -1) {
                              // Mevcut kartı güncelle
                              cards[existingIndex] = result;
                            } else {
                              // Yeni kart ekle
                              cards.add(result);
                            }
                          });
                        }
                      }
                    },
                  ),
                );
              }
            },
          ),
        ),
        SmoothPageIndicator(
          controller: _controller,
          count: cards.length + 1,
          effect: WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.blue,
            dotColor: Colors.grey,
          ),
          onDotClicked: (index) {
            _controller.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}
