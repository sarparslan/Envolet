import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:card_swiper/card_swiper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void searchButtonPressed() {
    print("searchButtonPressed");
  }

  void notificationbuttonPressed() {
    print("onBellPressed");
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

  List<Widget>? items = [1, 2, 3, 4, 5].map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(color: Colors.amber),
            child: Text(
              'text $i',
              style: TextStyle(fontSize: 16.0),
            ));
      },
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 60, left: 20),
            child: title(),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 30,
              left: 20,
            ),
            child: cardRow(),
          ),
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
        SizedBox(
          width: 100,
        ),
        IconButton(
          onPressed: searchButtonPressed,
          icon: Icon(
            FontAwesomeIcons.search,
            color: Colors.black,
          ),
          iconSize: 20,
        ),
        SizedBox(
          width: 30,
        ),
        IconButton(
          onPressed: notificationbuttonPressed,
          icon: Icon(FontAwesomeIcons.bell),
          color: Colors.black,
          iconSize: 20,
        ),
      ],
    );
  }

  Widget cardRow() {
    return Container(
      height: 200,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return CreditCardUi(
            scale: 0.9,
            cardHolderFullName: 'John Doe',
            cardNumber: '1234567812345678',
            validThru: '10/24',
          );
        },
        itemCount: 10,
        viewportFraction: 0.8,
        scale: 0.9,
        /*
                  pagination: SwiperPagination(
                    alignment: ,
                      builder: DotSwiperPaginationBuilder(
                    activeColor: Colors.blue, // Aktif bullet rengi
                    color: Colors.black54, // Pasif bullet rengi
                    size: 12.0, // Pasif bullet boyutu
                    activeSize: 12.0, // Aktif bullet boyutu
                  )
                  )*/
      ),
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
        children: [],
      ),
    );
  }
}
