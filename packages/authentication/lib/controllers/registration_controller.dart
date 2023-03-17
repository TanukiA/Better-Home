import 'package:authentication/models/customer.dart';
import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';

class RegistrationController extends ControllerMVC {
  late User _user;
  late Firestore _db;

  User get user => _user;

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  void sendPhoneNumber(BuildContext context, String phoneInput) {
    return User.sendPhoneNumber(context, phoneInput);
  }

  bool validEmailFormat(String email) {
    return User.validEmailFormat(email);
  }

  bool checkValid(bool isValidName, bool isValidEmail, bool isValidPhone) {
    if (isValidName && isValidEmail && isValidPhone) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isAccountExists(String phoneNumber, String userType) async {
    _db = Firestore();
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }

  void storeCustomerData(String phoneNumber, String name, String email) {
    _user = Customer(
        phone: phoneNumber.trim(), name: name.trim(), email: email.trim());
    Map<String, dynamic> customerData = {
      'phoneNumber': _user.phone,
      'name': _user.name,
      'email': _user.email,
    };
    _db.addCustomerData(customerData);
  }
}
