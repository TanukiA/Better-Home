import 'package:authentication/models/customer.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';

abstract class User extends ModelMVC {
  String? phone;
  String? name;
  String? email;
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

  static void sendPhoneNumber(BuildContext context, String phoneInput,
      String userType, String purpose) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneInput.trim();
    ap.signInWithPhone(context, phoneNumber, userType, purpose);
  }

  static bool validEmailFormat(String email) {
    if (email.isEmpty) return true;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  static void verifyOTP(
      BuildContext context,
      String userOTP,
      String verificationId,
      String userType,
      String purpose,
      String phoneNumber) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOTP(
        context: context,
        verificationId: verificationId,
        userOTP: userOTP,
        onSuccess: () {
          if (userType == "customer" && purpose == "login") {
            Customer customer = Customer();
            customer.login(context, phoneNumber);
          } else if (userType == "customer" && purpose == "register") {
            Customer customer = Customer();
            Map<String, dynamic> customerData =
                customer.getRegisterDataFromProvider(context);
            Firestore firestore = Firestore();
            firestore.addCustomerData(customerData);
            customer.login(context, phoneNumber);
          } else if (userType == "technician" && purpose == "login") {
          } else if (userType == "technician" && purpose == "register") {}
        });
  }

  void login(BuildContext context, String phoneNumber);

  void logout();
}
