import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';

class User extends ModelMVC {
  final String id;
  final String phone;
  final String name;
  final String email;

  User(
      {required this.id,
      required this.phone,
      required this.name,
      required this.email});

  User.withIdAndPhone(this.id, this.phone)
      : name = '',
        email = '';

  bool validPhoneFormat(String phone) {
    if ((phone.startsWith('+60') &&
            (phone.length == 12 || phone.length == 13)) ||
        phone.isEmpty) {
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  void sendPhoneNumber(BuildContext context, String phoneInput) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneInput.trim();
    ap.signInWithPhone(context, phoneNumber);
  }

  bool validEmailFormat(String email) {
    if (email.isEmpty) return true;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }
}
