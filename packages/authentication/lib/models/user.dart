import 'package:authentication/views/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_db/models/database.dart';

abstract class User extends ModelMVC {
  final String phone;
  final String name;
  final String email;
  // Notification notification;
  // Location address;

  User({required this.phone, required this.name, required this.email});

  static bool validPhoneFormat(String phone) {
    if ((phone.startsWith('+60') &&
            (phone.length == 12 || phone.length == 13)) ||
        phone.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static void sendPhoneNumber(BuildContext context, String phoneInput) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneInput.trim();
    ap.signInWithPhone(context, phoneNumber);
  }

  static bool validEmailFormat(String email) {
    if (email.isEmpty) return true;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  static void verifyOTP(
      BuildContext context, String userOTP, String verificationId) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOTP(
        context: context,
        verificationId: verificationId,
        userOTP: userOTP,
        onSuccess: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
          );
        });
  }

  void login();

  void logout();
}
