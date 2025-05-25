import 'package:envolet_frontend/Util/alart.dart';
import 'package:envolet_frontend/Util/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Widgets/bottomBarWidget.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final data = await Api.getTransactions();
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  void _confirmDeleteTransaction(
      BuildContext context, Map<String, dynamic> transaction) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Are you sure you want to delete this transaction?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction(transaction);
            },
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) async {
    final success = await Api.deleteTransaction(id: transaction['_id']);
    if (success) {
      Util.showSuccessAlert(context, "Transaction deleted successfully!");
      setState(() {
        transactions.removeWhere((item) => item["_id"] == transaction["_id"]);
      });
    } else {
      Util.errorAlertAndNavigate(
          context, "Failed to delete transaction.", "Error");
    }
  }

  void _showActionSheet(
      BuildContext context, Map<String, dynamic> transaction) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Edit', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(context);
              _openEditTransactionDialog(transaction);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Delete',
                style: TextStyle(color: CupertinoColors.destructiveRed)),
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteTransaction(context, transaction);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openAddTransactionDialog() {
    final TextEditingController amountController = TextEditingController();
    String selectedCategory = categories.first;
    DateTime selectedDate = DateTime.now();
    bool isButtonEnabled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              amountController.addListener(() {
                final amountText = amountController.text.trim();
                final formattedText = amountText.replaceAll(',', '');
                final parsed = double.tryParse(formattedText);
                final enable = parsed != null && parsed > 0;
                if (enable != isButtonEnabled) {
                  setState(() => isButtonEnabled = enable);
                }
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("New Expense",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SizedBox(
                          height: 250,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: categories.indexOf(selectedCategory),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedCategory = categories[index];
                              });
                            },
                            children: categories.map((e) => Text(e)).toList(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedCategory,
                              style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM, yyyy').format(selectedDate),
                              style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? Colors.blue
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isButtonEnabled
                          ? () async {
                              final parsed = double.tryParse(amountController
                                  .text
                                  .trim()
                                  .replaceAll(',', ''));
                              if (parsed == null) return;

                              final success = await Api.addTransaction(
                                amount: parsed,
                                category: selectedCategory,
                                date: DateFormat('yyyy-MM-dd')
                                    .format(selectedDate),
                              );

                              if (success) {
                                Navigator.of(context).pop();
                                Util.showTransactionSuccessBottomSheet(
                                  context,
                                  category: selectedCategory,
                                  amount: parsed,
                                  date: selectedDate,
                                );
                                fetchTransactions();
                              }
                            }
                          : null,
                      child: const Text("Add",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openEditTransactionDialog(Map<String, dynamic> transaction) {
    final TextEditingController amountController = TextEditingController(
        text: (transaction['amount'] as num?)?.toString() ?? '');
    String selectedCategory = transaction['category'] ?? categories.first;
    DateTime selectedDate =
        DateTime.tryParse(transaction['date']) ?? DateTime.now();
    bool isButtonEnabled = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              amountController.addListener(() {
                final amountText = amountController.text.trim();
                final parsed = double.tryParse(amountText);
                final enable = parsed != null && parsed > 0;
                if (enable != isButtonEnabled) {
                  setState(() => isButtonEnabled = enable);
                }
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Update Expense",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number, // Same as New Expense
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Ensures only digits are allowed
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SizedBox(
                          height: 250,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: categories.indexOf(selectedCategory),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedCategory = categories[index];
                              });
                            },
                            children: categories.map((e) => Text(e)).toList(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedCategory,
                              style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM, yyyy').format(selectedDate),
                              style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? Colors.blue
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isButtonEnabled
                          ? () async {
                              final parsed = double.tryParse(amountController
                                  .text
                                  .trim()
                                  .replaceAll(',', ''));
                              if (parsed == null) return;

                              final success = await Api.updateTransaction(
                                id: transaction["_id"],
                                amount: parsed,
                                category: selectedCategory,
                                date: DateFormat('yyyy-MM-dd')
                                    .format(selectedDate),
                              );

                              if (success) {
                                Navigator.of(context).pop();
                                Util.showTransactionUpdateSuccessBottomSheet(
                                  context,
                                  category: selectedCategory,
                                  amount: parsed,
                                  date: selectedDate,
                                );
                                fetchTransactions();
                              } else {
                                Util.errorAlertAndNavigate(context,
                                    "Failed to update transaction.", "Error");
                              }
                            }
                          : null,
                      child: const Text("Update",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    transactions.sort((a, b) => b["date"].compareTo(a["date"]));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text("Transactions", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("No transactions found"))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final date = DateTime.tryParse(tx["date"] ?? "");
                    final formattedDate = date != null
                        ? DateFormat('d MMM').format(date)
                        : "Invalid";

                    final category = tx["category"] ?? "Unknown";
                    final icon = categoryIcons[category] ?? Icons.category;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
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
                                  "$formattedDate",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                (tx["amount"] ?? 0).toString(),
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
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _showActionSheet(context, tx),
                                child: const Icon(
                                  CupertinoIcons.ellipsis_vertical,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
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
