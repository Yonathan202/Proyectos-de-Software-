import 'package:flutter/services.dart';

class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    return TextEditingValue(
      text: '\$' + text,
      selection: TextSelection.collapsed(offset: text.length + 1),
    );
  }
}
