import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/utils/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envolet_frontend/utils/thousands_formatter.dart';

class CardAdditionDialog extends StatefulWidget {
  final Map<String, String>? initialData;

  const CardAdditionDialog({super.key, this.initialData});

  @override
  State<CardAdditionDialog> createState() => _CardAdditionDialogState();
}

class _CardAdditionDialogState extends State<CardAdditionDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _bankName;
  late String _amount;
  late String _cardTail;
  String _selectedCardBrand = "";
  late Color _cardColor;

  final List<String> _cardBrandOptions = [
    'Visa',
    'MasterCard',
    'American Express',
    'Discover',
    'Amazon Pay',
    'Apple Pay',
    'Paypal',
    'Other',
  ];

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
    _amount = (widget.initialData?['balance'] ?? '').replaceAll(',', '');
    _cardTail = widget.initialData?['cardTail'] ?? '';
    _selectedCardBrand = widget.initialData?['cardBrand'] ?? '';

    if (widget.initialData != null &&
        widget.initialData!.containsKey('color')) {
      final Color chosenColor = _hexToColor(widget.initialData!['color']!);
      int index = _colorOptions
          .indexWhere((c) => c.toARGB32() == chosenColor.toARGB32());
      if (index != -1) {
        _cardColor = _colorOptions[index];
      } else {
        _cardColor = Colors.blue;
      }
    } else {
      _cardColor = Colors.blue;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  void _saveCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final plainAmount = _amount.replaceAll(',', '');
      final int amountInt = int.tryParse(plainAmount) ?? 0;
      final String colorHex = _colorToHex(_cardColor);

      final bool isUpdate = widget.initialData?['_id'] != null;

      if (isUpdate) {
        final success = await ApiService.updateAsset(
          id: widget.initialData!['_id']!,
          bankName: _bankName,
          amount: amountInt,
          lastFourDigits: _cardTail,
          brand: _selectedCardBrand,
          color: colorHex,
        );

        if (!mounted) return;
        if (success) {
          AppDialogs.showCardActionSuccess(
            context,
            "Your card was successfully updated.",
            onContinue: () {
              Navigator.of(context).pop({'updated': 'true'});
            },
          );
        }
      } else {
        Map<String, String> cardData = {
          'bankName': _bankName,
          'balance': plainAmount,
          'color': colorHex,
          'cardTail': _cardTail,
          'cardBrand': _selectedCardBrand,
        };
        Navigator.pop(context, cardData);
      }
    }
  }

  void _deleteCard() async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
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
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Yes", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted) return;
    if (confirm) {
      Navigator.of(context).pop({'delete': 'true'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.blue.withValues(alpha: 0.3),
        splashColor: Colors.blue.withValues(alpha: 0.2),
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
          widget.initialData != null ? 'Update Asset' : 'Add Card',
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

                _buildTextField(
                  label: 'Amount ($globalCurrency)',
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
                _buildCardBrandCupertinoPicker(),
                SizedBox(height: 8),
                _buildCardColorCupertinoPicker(),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),

              if (widget.initialData != null)
                ElevatedButton(
                  onPressed: _deleteCard,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete Card',
                      style: TextStyle(color: Colors.white)),
                ),

              SizedBox(width: 10),

              // Save
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
    final focusNode = FocusNode();
    return StatefulBuilder(
      builder: (context, setState) {
        focusNode.addListener(() {
          setState(() {});
        });

        return TextFormField(
          focusNode: focusNode,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: focusNode.hasFocus ? Colors.blue : Colors.grey,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          style: TextStyle(color: Colors.black),
        );
      },
    );
  }

  Widget _buildCardBrandCupertinoPicker() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return SizedBox(
              height: 250,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: _cardBrandOptions.indexOf(
                      _selectedCardBrand.isNotEmpty
                          ? _selectedCardBrand
                          : _cardBrandOptions[0]),
                ),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedCardBrand = _cardBrandOptions[index];
                  });
                },
                children: _cardBrandOptions
                    .map((brand) =>
                        Text(brand, style: TextStyle(color: Colors.black)))
                    .toList(),
              ),
            );
          },
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Card Brand',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: _selectedCardBrand),
        ),
      ),
    );
  }

  Widget _buildCardColorCupertinoPicker() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return SizedBox(
              height: 250,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: _colorOptions.indexOf(_cardColor),
                ),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _cardColor = _colorOptions[index];
                  });
                },
                children: _colorOptions.map((color) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: color,
                        margin: EdgeInsets.only(right: 8),
                      ),
                      Text(_colorLabels[color] ?? '',
                          style: TextStyle(color: Colors.black)),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Card Color',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: _colorLabels[_cardColor]),
        ),
      ),
    );
  }
}
