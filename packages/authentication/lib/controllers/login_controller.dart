import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';

class LoginController extends ControllerMVC {
  late User _user;
  late Database _db;

  User get user => _user;

  LoginController() {
    _user = Technician();
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
    _db = Database();
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }

  Future<bool> isApprovedAccount(String phoneNumber) async {
    _db = Database();
    final approved = await _db.checkApprovalStatus(phoneNumber);
    return approved;
  }

  void logout(BuildContext context) {
    return _user.logout(context);
  }
}
