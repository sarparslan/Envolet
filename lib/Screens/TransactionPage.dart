import 'package:flutter/material.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<Map<String, dynamic>> transactions = [
    {
      "amount": 120.5,
      "category": "Food",
      "icon": Icons.fastfood,
      "date": DateTime.now().subtract(Duration(days: 1)),
      "currency": "EUR",
      "card": "Visa"
    },
    {
      "amount": 45.0,
      "category": "Transport",
      "icon": Icons.directions_car,
      "date": DateTime.now().subtract(Duration(days: 2)),
      "currency": "USD",
      "card": "Mastercard"
    },
  ];

  void _openAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: _buildAddTransactionForm(),
      ),
    );
  }

  Widget _buildAddTransactionForm() {
    final TextEditingController amountController = TextEditingController();
    String? selectedCategory;
    DateTime selectedDate = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Yeni Harcama Ekle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Tutar'),
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: "Kategori"),
            items: [
              DropdownMenuItem(value: "Food", child: Text("Yemek")),
              DropdownMenuItem(value: "Transport", child: Text("Ulaşım")),
              DropdownMenuItem(value: "Shopping", child: Text("Alışveriş")),
            ],
            onChanged: (val) {
              selectedCategory = val;
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                selectedDate = pickedDate;
              }
            },
            child: Text("Tarih Seç"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Add transaction logic (You should update your model accordingly)
              Navigator.of(context).pop();
            },
            child: Text("Ekle"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    transactions
        .sort((a, b) => b["date"].compareTo(a["date"])); // En yeni en üstte

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Transactions", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: Icon(tx["icon"], color: Colors.black),
            title:
                Text("${tx["category"]} - ${tx["amount"]} ${tx["currency"]}"),
            subtitle: Text(
                "${tx["date"].toLocal().toString().split(" ")[0]} - ${tx["card"]}"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: BottomNavBarWidget(currentPage: Pages.TransactionPage),
      ),
    );
  }
}
