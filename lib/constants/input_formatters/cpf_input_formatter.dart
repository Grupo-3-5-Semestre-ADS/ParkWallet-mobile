import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final selectionIndex = digitsOnly.length;

    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 11; i++) {
      formatted += digitsOnly[i];
      if (i == 2 || i == 5) formatted += '.';
      if (i == 8) formatted += '-';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: _getCursorPosition(formatted, selectionIndex)),
    );
  }

  int _getCursorPosition(String formattedText, int digitCount) {
    if (digitCount <= 3) return digitCount;
    if (digitCount <= 6) return digitCount + 1;
    if (digitCount <= 9) return digitCount + 2;
    return digitCount + 3;
  }
}
