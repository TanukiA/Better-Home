import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RegistrationController extends ControllerMVC {
  late User _user;

  RegistrationController() {
    _user = User(id: '', phone: '', name: '', email: '');
  }

  User get user => _user;

  String validPhoneFormat(String phone) {
    return _user.validPhoneFormat(phone);
  }

  void sendPhoneNumber(BuildContext context, String phoneInput) {
    return _user.sendPhoneNumber(context, phoneInput);
  }
}
