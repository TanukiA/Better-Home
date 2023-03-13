import 'package:authentication/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';

class LoginController extends ControllerMVC {
  /*
  factory LoginController() => _this ??= LoginController._();
  LoginController._();
  static LoginController? _this;
*/
  late User _user;

  LoginController() {
    _user = User(id: '', phone: '', name: '', email: '');
  }

  User get user => _user;

  String validPhoneFormat(String phone) {
    return _user.validPhoneFormat(phone);
  }
}
