import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(newText) / 100;

    String newFormatted = formatter.format(value).trim();

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: newFormatted.length),
    );
  }
}
