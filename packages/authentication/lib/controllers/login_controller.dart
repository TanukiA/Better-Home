import 'package:authentication/models/customer.dart';
import 'package:authentication/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';

class LoginController extends ControllerMVC {
  late User _user;
  late Firestore _db;

  User get user => _user;

  LoginController() {
    _user = Customer(phone: '', name: '', email: '');
  }

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  void sendPhoneNumber(BuildContext context, String phoneInput, String userType,
      String purpose) {
    return User.sendPhoneNumber(context, phoneInput, userType, purpose);
  }

  void verifyOTP(BuildContext context, String userOTP, String verificationId,
      String userType, String purpose, String phoneNumber) {
    return User.verifyOTP(
        context, userOTP, verificationId, userType, purpose, phoneNumber);
  }

  Future<bool> isAccountExists(String phoneNumber, String userType) async {
    _db = Firestore();
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }
}
