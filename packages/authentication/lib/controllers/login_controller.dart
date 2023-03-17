import 'package:authentication/models/customer.dart';
import 'package:authentication/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';

class LoginController extends ControllerMVC {
  late User _user;
  late Firestore _db;

  User get user => _user;

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  void verifyOTP(BuildContext context, String userOTP, String verificationId) {
    return User.verifyOTP(context, userOTP, verificationId);
  }

  Future<bool> isAccountExists(String phoneNumber, String userType) async {
    _db = Firestore();
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }
}
