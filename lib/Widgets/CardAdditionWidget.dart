import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envolet_frontend/Util/Helper/ThousandsFormatter.dart';

class CardAdditionDialog extends StatefulWidget {
  final Map<String, String>? initialData; // For editing existing card data

  const CardAdditionDialog({Key? key, this.initialData}) : super(key: key);

  @override
  _CardAdditionDialogState createState() => _CardAdditionDialogState();
}

class _CardAdditionDialogState extends State<CardAdditionDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _bankName;
  late String _amount;
  late String _cardTail;
  String _selectedCardBrand = "";
  late Color _cardColor;
  late String _selectedCurrency;

  final List<String> _currencyOptions = [
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "AUD",
    "CAD",
    "CHF",
    "CNY",
    "SEK",
    "TL"
  ];

  // 5 popular card brands + an empty one for "None"
  final List<String> _cardBrandOptions = [
    '',
    'Visa',
    'MasterCard',
    'American Express',
    'Discover',
    'Amazon Pay',
    'Apple Pay',
    'Paypal'
  ];

  // Predefined color options
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.pink,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  final Map<Color, String> _colorLabels = {
    Colors.blue: 'Blue',
    Colors.red: 'Red',
    Colors.green: 'Green',
    Colors.orange: 'Orange',
    Colors.purple: 'Purple',
    Colors.yellow: 'Yellow',
    Colors.teal: 'Teal',
    Colors.indigo: 'Indigo',
    Colors.cyan: 'Cyan',
    Colors.lime: 'Lime',
    Colors.pink: 'Pink',
    Colors.amber: 'Amber',
    Colors.deepOrange: 'Deep Orange',
    Colors.deepPurple: 'Deep Purple',
  };

  @override
  void initState() {
    super.initState();
    _bankName = widget.initialData?['bankName'] ?? '';
    // Remove commas if any stored
    _amount = (widget.initialData?['balance'] ?? '').replaceAll(',', '');
    _cardTail = widget.initialData?['cardTail'] ?? '';
    _selectedCardBrand = widget.initialData?['cardBrand'] ?? '';
    _selectedCurrency = widget.initialData?['currency'] ?? _currencyOptions[0];

    if (widget.initialData != null &&
        widget.initialData!.containsKey('color')) {
      final Color chosenColor = _hexToColor(widget.initialData!['color']!);
      int index = _colorOptions.indexWhere((c) => c.value == chosenColor.value);
      if (index != -1) {
        _cardColor = _colorOptions[index];
      } else {
        _cardColor = Colors.blue;
      }
    } else {
      _cardColor = Colors.blue;
    }
  }

  // Convert hex string to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF" + hex;
    return Color(int.parse(hex, radix: 16));
  }

  // Convert Color to hex string
  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  void _saveCard() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Remove commas for storage
      final String plainAmount = _amount.replaceAll(',', '');
      final String cardNumber = widget.initialData != null
          ? widget.initialData!['cardNumber']!
          : DateTime.now().millisecondsSinceEpoch.toString();

      String colorHex = _colorToHex(_cardColor);

      Map<String, String> cardData = {
        'cardNumber': cardNumber,
        'bankName': _bankName,
        'balance': plainAmount,
        'currency': _selectedCurrency,
        'color': colorHex,
        'cardTail': _cardTail,
        'cardBrand': _selectedCardBrand,
      };

      Navigator.pop(context, cardData);
    }
  }

  void _deleteCard() async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: Colors.blue,
                  secondary: Colors.blue,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                title:
                    Text("Confirmation", style: TextStyle(color: Colors.black)),
                content: Text(
                  "Are you sure you want to delete this card?",
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("No", style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Yes", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (confirm) {
      Navigator.pop(context, {
        'delete': 'true',
        'cardNumber': widget.initialData!['cardNumber']!,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.blue.withOpacity(0.3),
        splashColor: Colors.blue.withOpacity(0.2),
        focusColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.blue,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blue.shade200,
          selectionHandleColor: Colors.blue,
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          widget.initialData != null ? 'Edit Card' : 'Add Card',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Bank Name
                _buildTextField(
                  label: 'Bank Name',
                  initialValue: _bankName,
                  onSaved: (val) => _bankName = val!,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Please enter the bank name.'
                      : null,
                ),
                SizedBox(height: 8),
                // Amount
                _buildTextField(
                  label: 'Amount',
                  initialValue: _amount,
                  onSaved: (val) => _amount = val!,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter the amount.';
                    }
                    final plain = val.replaceAll(',', '');
                    final number = double.tryParse(plain);
                    if (number == null) {
                      return 'Please enter a valid number.';
                    }
                    if (number > 100000000) {
                      return 'Amount too high. Maximum is 100,000,000.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsFormatter()],
                ),
                SizedBox(height: 8),
                // Currency
                _buildCurrencyDropdown(),
                SizedBox(height: 8),
                // Last 4 Digits
                _buildTextField(
                  label: 'Last 4 Digits',
                  initialValue: _cardTail,
                  onSaved: (val) => _cardTail = val!,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter last 4 digits.';
                    }
                    if (val.length != 4) {
                      return 'Must be exactly 4 digits.';
                    }
                    if (int.tryParse(val) == null) {
                      return 'Numbers only.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                // Card Brand
                _buildCardBrandDropdown(),
                SizedBox(height: 8),
                // Card Color
                _buildCardColorDropdown(),
              ],
            ),
          ),
        ),
        // Actions: Cancel, Delete, Save on the same row
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              // Delete Card
              if (widget.initialData != null)
                TextButton(
                  onPressed: _deleteCard,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child:
                      Text('Delete Card', style: TextStyle(color: Colors.red)),
                ),
              // Save
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  /// Currency Dropdown
  Widget _buildCurrencyDropdown() {
    return Row(
      children: [
        Text('Currency:', style: TextStyle(color: Colors.blue)),
        SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCurrency,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            dropdownColor: Colors.white,
            items: _currencyOptions.map((currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCurrency = val);
            },
          ),
        ),
      ],
    );
  }

  /// Card Brand Dropdown
  Widget _buildCardBrandDropdown() {
    return Row(
      children: [
        Text('Card Brand:', style: TextStyle(color: Colors.blue)),
        SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedCardBrand.isNotEmpty ? _selectedCardBrand : null,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            dropdownColor: Colors.white,
            hint: Text("Select Card Brand",
                style: TextStyle(color: Colors.black)),
            items: _cardBrandOptions.map((brand) {
              return DropdownMenuItem<String>(
                value: brand,
                child: Text(brand.isEmpty ? "None" : brand,
                    style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedCardBrand = val ?? "");
            },
          ),
        ),
      ],
    );
  }

  /// Card Color Dropdown
  Widget _buildCardColorDropdown() {
    return Row(
      children: [
        Text('Card Color:', style: TextStyle(color: Colors.blue)),
        SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<Color>(
            value: _cardColor,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            dropdownColor: Colors.white,
            items: _colorOptions.map((color) {
              return DropdownMenuItem<Color>(
                value: color,
                child: Row(
                  children: [
                    Container(width: 20, height: 20, color: color),
                    SizedBox(width: 8),
                    Text(_colorLabels[color] ?? '',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Color? newColor) {
              if (newColor != null) {
                setState(() => _cardColor = newColor);
              }
            },
          ),
        ),
      ],
    );
  }
}
