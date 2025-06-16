import 'package:envolet_frontend/core/constants.dart';
import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/utils/formatters.dart';
import 'package:envolet_frontend/utils/thousands_formatter.dart';
import 'package:envolet_frontend/widgets/cupertino_select_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Values entered in [TransactionFormSheet].
class TransactionFormResult {
  const TransactionFormResult({
    required this.amount,
    required this.category,
    required this.date,
  });

  final double amount;
  final String category;
  final DateTime date;
}

/// Bottom sheet for creating a new expense or editing an existing one.
class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({super.key, this.initial});

  final Transaction? initial;

  static Future<TransactionFormResult?> show(
    BuildContext context, {
    Transaction? initial,
  }) {
    return showModalBottomSheet<TransactionFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionFormSheet(initial: initial),
    );
  }

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  late final TextEditingController _amountController;
  late String _category;
  late DateTime _date;

  bool get _isEditing => widget.initial != null;

  double? get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', ''));

  bool get _canSubmit => (_amount ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _amountController = TextEditingController(
      text: initial == null ? '' : formatAmount(initial.amount.round()),
    )..addListener(() => setState(() {}));
    _category = initial?.category ?? categories.first;
    _date = initial?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    Navigator.of(context).pop(
      TransactionFormResult(amount: _amount!, category: _category, date: _date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isEditing ? 'Update Expense' : 'New Expense',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: !_isEditing,
            decoration: InputDecoration(
              labelText: 'Amount',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            inputFormatters: [ThousandsFormatter()],
          ),
          const SizedBox(height: 16),
          CupertinoSelectField<String>(
            value: _category,
            options: categories,
            labelBuilder: (category) => category,
            onChanged: (category) => setState(() => _category = category),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd MMM, yyyy').format(_date),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEditing ? 'Update' : 'Add',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
