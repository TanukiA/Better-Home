import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_data/models/database.dart';
import 'package:better_home/utils.dart';

class LoginController extends ControllerMVC {
  late User _user;
  late Database _db;

  User get user => _user;

  LoginController(String userType) {
    if (userType == 'technician') {
      _user = Technician(
          address: '',
          city: '',
          exp: '',
          lat: 0.0,
          lng: 0.0,
          specs: [],
          pickedFile: PlatformFile(name: '', size: 0),
          dateTimeRegistered: DateTime(2023));
    } else if (userType == 'customer') {
      _user = Customer();
    } else {
      throw Exception('Invalid userType');
    }
    _db = Database();
  }

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  void sendPhoneNumber(BuildContext context, String phoneInput, String userType,
      String purpose) {
    return _user.sendPhoneNumber(context, phoneInput, userType, purpose);
  }

  void verifyOTP(BuildContext context, String userOTP, String verificationId,
      String userType, String purpose, String phoneNumber) {
    return _user.verifyOTP(
        context, userOTP, verificationId, userType, purpose, phoneNumber);
  }

  Future<bool> isAccountExists(String phoneNumber, String userType) async {
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }

  Future<bool> isApprovedAccount(String phoneNumber) async {
    final approved = await _db.checkApprovalStatus(phoneNumber);
    return approved;
  }

  void showUnregisteredError(BuildContext context) {
    showDialogBox(context, "Unregistered phone number",
        "Please login with a registered number.");
  }

  void showUnapprovedError(BuildContext context) {
    showDialogBox(context, "Unapproved account",
        "Please wait for admin's approval email.");
  }

  void logout(BuildContext context) {
    return _user.logout(context);
  }
}
