import 'package:flutter/services.dart';

class PhoneOrNameInputFormatter extends TextInputFormatter {
  PhoneOrNameInputFormatter({this.maxDigits = 9, this.maxNameLength = 60});

  final int maxDigits;
  final int maxNameLength;

  static final RegExp _letters = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]');
  static final RegExp _separators = RegExp(r'[\s-]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (_letters.hasMatch(text)) {
      if (text.length > maxNameLength) return oldValue;
      return _atEnd(text);
    }

    final digits = text.replaceAll(_separators, '');
    final limited = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;

    return _atEnd(limited);
  }

  TextEditingValue _atEnd(String text) {
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}
