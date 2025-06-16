import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/widgets/bottom_nav_bar.dart';
import 'package:envolet_frontend/widgets/transaction_form_sheet.dart';
import 'package:envolet_frontend/widgets/transaction_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late final ApiService _api = context.read<ApiService>();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _api.getTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _error = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTransaction() async {
    final form = await TransactionFormSheet.show(context);
    if (form == null) return;
    await _save(
      () => _api.addTransaction(
        amount: form.amount,
        category: form.category,
        date: form.date,
      ),
      form: form,
      isUpdate: false,
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final form = await TransactionFormSheet.show(context, initial: transaction);
    if (form == null) return;
    await _save(
      () => _api.updateTransaction(
        id: transaction.id,
        amount: form.amount,
        category: form.category,
        date: form.date,
      ),
      form: form,
      isUpdate: true,
    );
  }

  Future<void> _save(
    Future<void> Function() request, {
    required TransactionFormResult form,
    required bool isUpdate,
  }) async {
    try {
      await request();
      if (!mounted) return;
      AppDialogs.showTransactionSaved(
        context,
        isUpdate: isUpdate,
        category: form.category,
        amount: form.amount,
        date: form.date,
      );
      _loadTransactions();
    } on ApiException {
      if (!mounted) return;
      AppDialogs.showError(
        context,
        isUpdate
            ? 'Failed to update transaction.'
            : 'Failed to add transaction.',
      );
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await _api.deleteTransaction(transaction.id);
      if (!mounted) return;
      setState(() => _transactions.remove(transaction));
      AppDialogs.showSuccess(context, 'Transaction deleted successfully!');
    } on ApiException {
      if (mounted) {
        AppDialogs.showError(context, 'Failed to delete transaction.');
      }
    }
  }

  void _confirmDelete(Transaction transaction) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteTransaction(transaction);
            },
          ),
        ],
      ),
    );
  }

  void _showActions(Transaction transaction) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Edit', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.pop(sheetContext);
              _editTransaction(transaction);
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(sheetContext);
              _confirmDelete(transaction);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(sheetContext),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Transactions', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar:
          const BottomNavBarWidget(currentPage: Pages.transaction),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _transactions.isEmpty) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    if (_transactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionTile(
            transaction: transaction,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(32),
              onPressed: () => _showActions(transaction),
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
