import 'package:dotted_border/dotted_border.dart';
import 'package:envolet_frontend/Widgets/CardAdditionWidget.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:flutter/material.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  List<Map<String, String>> _cards = [];
  int? selectedCardIndex;

  @override
  void initState() {
    super.initState();
    _loadMockCards();
  }

  void _loadMockCards() {
    final colors = [
      '#FF3B3B',
      '#2B7A78',
      '#364F6B',
      '#6C5CE7',
      '#00B894',
      '#FDCB6E',
      '#D63031',
      '#0984E3',
      '#FAB1A0',
      '#A29BFE',
    ];
    _cards = List.generate(10, (i) {
      return {
        'cardNumber': '${i + 1}',
        'bankName': 'Bank ${i + 1}',
        'balance': '${(i + 1) * 150}',
        'currency': '₺',
        'color': colors[i % colors.length],
        'cardTail': '${1000 + i * 13}',
        'cardBrand': 'Visa',
      };
    });
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildCard(Map<String, String> card, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isSelected ? 220 : 160,
      decoration: BoxDecoration(
        color: _hexToColor(card['color']!),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card['bankName'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          Text('**** **** **** ${card['cardTail'] ?? '--'}',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${card['balance']} ${card['currency']}',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedWalletCards() {
    const double baseCardHeight = 160;
    const double overlap = 50;

    return SizedBox(
      height: baseCardHeight + (_cards.length - 2) * overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(_cards.length, (i) {
          final index = _cards.length - 1 - i;
          final isTopCard = index == 0;
          final isSelected = selectedCardIndex == index;

          return Positioned(
            top: i * overlap,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (!isTopCard) {
                  setState(() {
                    selectedCardIndex =
                        selectedCardIndex == index ? null : index;
                  });
                }
              },
              child: _buildCard(_cards[index], isTopCard || isSelected),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddCardBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final newCard = await showDialog<Map<String, String>>(
            context: context,
            builder: (context) => CardAdditionDialog(),
          );
          if (newCard != null) {
            setState(() {
              _cards.add(newCard);
            });
          }
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          padding: EdgeInsets.all(20),
          color: Colors.grey,
          dashPattern: [8, 4],
          strokeWidth: 2,
          child: Center(
            child: Column(
              children: [
                Icon(Icons.add, size: 32, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "Tap to add a new card",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Assets",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildStackedWalletCards(),
              const SizedBox(height: 40),
              _buildAddCardBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.03),
        child: BottomNavBarWidget(currentPage: Pages.AssetsPage),
      ),
    );
  }
}
