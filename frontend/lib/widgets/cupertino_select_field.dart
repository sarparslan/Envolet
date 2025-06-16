import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Read-only field that opens a wheel picker to choose one of [options].
class CupertinoSelectField<T> extends StatelessWidget {
  const CupertinoSelectField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
    this.label,
    this.itemBuilder,
    this.trailingIcon = Icons.arrow_drop_down,
  });

  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;
  final Widget Function(T)? itemBuilder;
  final String? label;
  final IconData trailingIcon;

  void _openPicker(BuildContext context) {
    FocusScope.of(context).unfocus();
    final initialIndex = options.indexOf(value);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SizedBox(
        height: 250,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 36,
          scrollController: FixedExtentScrollController(
            initialItem: initialIndex < 0 ? 0 : initialIndex,
          ),
          onSelectedItemChanged: (index) => onChanged(options[index]),
          children: options
              .map((option) => Center(
                    child:
                        itemBuilder?.call(option) ?? Text(labelBuilder(option)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
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
                labelBuilder(value),
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(trailingIcon, size: 20),
          ],
        ),
      ),
    );
  }
}
