import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/alart.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:envolet_frontend/Util/Widgets/CardAdditionWidget.dart';
import 'package:envolet_frontend/Util/Widgets/CreditCard.dart';
import 'package:envolet_frontend/Util/Widgets/bottomBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;
  List<Map<String, dynamic>> latestTransactions = [];
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.8);
    _fetchLatestTransactions();
    _fetchAssets();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestTransactions() async {
    final transactions = await Api.getTransactions();
    transactions.sort((a, b) => b["date"].compareTo(a["date"]));
    setState(() {
      latestTransactions = transactions.take(3).toList();
    });
  }

  Future<void> _fetchAssets() async {
    final assets = await Api.getAssets();
    setState(() {
      cards = List.from(assets.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 80, left: 20, bottom: 15),
              child: title(),
            ),
            cardRow(),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Row(
                children: [
                  Text(
                    'Latest Transactions',
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
              child: latestTransactionsRow(),
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
          ("Welcome, " +
                  (userName.toString() + " " + userSurname.toString())) ??
              "",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget latestTransactionsRow() {
    return Column(
      children: latestTransactions.map((tx) {
        final date = DateTime.tryParse(tx["date"] ?? "");
        final formattedDate =
            date != null ? DateFormat('d MMM').format(date) : "Invalid";

        final category = tx["category"] ?? "Unknown";
        final icon = categoryIcons[category] ?? Icons.category;
        final amount = tx["amount"]?.toString() ?? "0";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(icon, color: Colors.blue, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FaIcon(
                    currencyIcons[globalCurrency] ??
                        FontAwesomeIcons.moneyBillWave,
                    size: 16,
                    color: Colors.black87,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget cardRow() {
    return Column(
      children: [
        Container(
          height: 240,
          width: 800,
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
                        final amountInt =
                            int.tryParse(newCard['balance'] ?? '0') ?? 0;

                        final createdAsset = await Api.addAsset(
                          bankName: newCard['bankName']!,
                          amount: amountInt,
                          lastFourDigits: newCard['cardTail']!,
                          brand: newCard['cardBrand']!,
                          color: newCard['color']!,
                        );

                        if (createdAsset != null) {
                          await _fetchAssets();

                          // ✅ Success Alert
                          Util.showSuccessAlertForCardUpdateaAdDelete(
                            context,
                            "Your card was successfully added.",
                            onContinue: () {},
                          );
                        } else {
                          Util.errorAlertAndNavigate(
                            context,
                            "Something went wrong while adding the card.",
                            "Error",
                          );
                        }
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
                final card = cards[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: CustomCreditCard(
                      cardTail: card['lastFourDigits'] ?? '',
                      bankName: card['bankName'] ?? '',
                      balance: card['amount'].toString(),
                      colorHex: card['color'] ?? '',
                      cardBrand: card['brand'] ?? '',
                      onEditPressed: () async {
                        final result = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (context) => CardAdditionDialog(
                            initialData: {
                              'bankName': card['bankName'] ?? '',
                              'balance': card['amount'].toString(),
                              'color': card['color'] ?? '',
                              'cardTail': card['lastFourDigits'] ?? '',
                              'cardBrand': card['brand'] ?? '',
                              '_id': card['_id'] ?? '',
                            },
                          ),
                        );

                        if (result != null) {
                          if (result['delete'] == 'true') {
                            await Api.deleteAsset(card['_id']);
                            await _fetchAssets();

                            Util.showSuccessAlertForCardUpdateaAdDelete(
                              context,
                              "Your card was successfully deleted.",
                              onContinue: () {},
                            );
                            return;
                          }

                          if (result['updated'] == 'true') {
                            await _fetchAssets();
                          }
                        }
                      }),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
