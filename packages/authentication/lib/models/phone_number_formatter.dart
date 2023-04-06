import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MalaysiaPhoneNumberFormatter extends TextInputFormatter {
  final BuildContext context;

  MalaysiaPhoneNumberFormatter(this.context);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (digitsOnly.startsWith('60')) {
      // Check if the phone number has 11 or 12 digits (e.g. 60192873648)
      if (digitsOnly.length == 11 || digitsOnly.length == 12) {
        String formattedValue = '+$digitsOnly';
        return TextEditingValue(
            text: formattedValue,
            selection: TextSelection.collapsed(offset: formattedValue.length));
      }
    } else if (digitsOnly.startsWith('0')) {
      // Check if the phone number has 10 or 11 digits (e.g. 0192873648)
      if (digitsOnly.length == 10 || digitsOnly.length == 11) {
        String formattedValue = '+6$digitsOnly';
        return TextEditingValue(
            text: formattedValue,
            selection: TextSelection.collapsed(offset: formattedValue.length));
      }
    }

    return TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length));
  }
}
