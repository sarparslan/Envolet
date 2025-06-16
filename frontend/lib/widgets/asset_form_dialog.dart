import 'package:envolet_frontend/models/asset.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/utils/formatters.dart';
import 'package:envolet_frontend/utils/thousands_formatter.dart';
import 'package:envolet_frontend/widgets/cupertino_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Result returned when [AssetFormDialog] is closed.
sealed class AssetFormResult {
  const AssetFormResult();
}

class AssetSaved extends AssetFormResult {
  const AssetSaved(this.draft);
  final AssetDraft draft;
}

class AssetDeleted extends AssetFormResult {
  const AssetDeleted();
}

/// Dialog for creating a new card or editing an existing one.
class AssetFormDialog extends StatefulWidget {
  const AssetFormDialog({super.key, this.initial});

  /// The asset being edited, or null when adding a new one.
  final Asset? initial;

  static Future<AssetFormResult?> show(BuildContext context, {Asset? initial}) {
    return showDialog<AssetFormResult>(
      context: context,
      builder: (_) => AssetFormDialog(initial: initial),
    );
  }

  @override
  State<AssetFormDialog> createState() => _AssetFormDialogState();
}

class _AssetFormDialogState extends State<AssetFormDialog> {
  static const int _maxAmount = 100000000;

  static const List<String> _brands = [
    'Visa',
    'MasterCard',
    'American Express',
    'Discover',
    'Amazon Pay',
    'Apple Pay',
    'Paypal',
    'Other',
  ];

  static const Map<String, Color> _colors = {
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Yellow': Colors.yellow,
    'Teal': Colors.teal,
    'Indigo': Colors.indigo,
    'Cyan': Colors.cyan,
    'Lime': Colors.lime,
    'Pink': Colors.pink,
    'Amber': Colors.amber,
    'Deep Orange': Colors.deepOrange,
    'Deep Purple': Colors.deepPurple,
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _lastDigitsController;
  late String _brand;
  late String _colorName;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _bankNameController = TextEditingController(text: initial?.bankName);
    _amountController = TextEditingController(
      text: initial == null ? '' : formatAmount(initial.amount),
    );
    _lastDigitsController =
        TextEditingController(text: initial?.lastFourDigits);
    _brand = _brands.contains(initial?.brand) ? initial!.brand : _brands.first;
    _colorName = _colorNameFor(initial?.color) ?? _colors.keys.first;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _amountController.dispose();
    _lastDigitsController.dispose();
    super.dispose();
  }

  String? _colorNameFor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final argb = colorFromHex(hex).toARGB32();
    for (final entry in _colors.entries) {
      if (entry.value.toARGB32() == argb) return entry.key;
    }
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = AssetDraft(
      bankName: _bankNameController.text.trim(),
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      lastFourDigits: _lastDigitsController.text,
      brand: _brand,
      color: colorToHex(_colors[_colorName]!),
    );
    Navigator.of(context).pop(AssetSaved(draft));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const AssetDeleted());
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the amount.';
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null) return 'Please enter a valid number.';
    if (number > _maxAmount) {
      return 'Amount too high. Maximum is ${formatAmount(_maxAmount)}.';
    }
    return null;
  }

  String? _validateLastDigits(String? value) {
    if (value == null || value.isEmpty) return 'Please enter last 4 digits.';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'Must be exactly 4 digits.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currency;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(_isEditing ? 'Update Asset' : 'Add Card'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textField(
                controller: _bankNameController,
                label: 'Bank Name',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter the bank name.'
                    : null,
              ),
              const SizedBox(height: 8),
              _textField(
                controller: _amountController,
                label: 'Amount ($currency)',
                validator: _validateAmount,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
              ),
              const SizedBox(height: 8),
              _textField(
                controller: _lastDigitsController,
                label: 'Last 4 Digits',
                validator: _validateLastDigits,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              const SizedBox(height: 8),
              CupertinoSelectField<String>(
                label: 'Card Brand',
                value: _brand,
                options: _brands,
                labelBuilder: (brand) => brand,
                onChanged: (brand) => setState(() => _brand = brand),
              ),
              const SizedBox(height: 8),
              CupertinoSelectField<String>(
                label: 'Card Color',
                value: _colorName,
                options: _colors.keys.toList(),
                labelBuilder: (name) => name,
                itemBuilder: (name) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: _colors[name],
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(name),
                  ],
                ),
                onChanged: (name) => setState(() => _colorName = name),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditing)
          ElevatedButton(
            onPressed: _delete,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete Card',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}
