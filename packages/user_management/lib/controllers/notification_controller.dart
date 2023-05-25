import 'package:authentication/models/auth_provider.dart';
import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/models/message.dart';

class NotificationController extends ControllerMVC {
  late Message _message;
  late User _user;

  User get user => _user;
  Message get message => _message;

  NotificationController(bool msg, [String userType = ""]) {
    if (msg) {
      _message = Message();
    } else {
      if (userType == "customer") {
        _user = Customer();
      } else if (userType == "technician") {
        _user = Technician(
            address: '',
            city: '',
            exp: '',
            lat: 0.0,
            lng: 0.0,
            specs: [],
            pickedFile: PlatformFile(name: '', size: 0));
      } else {
        throw Exception('Invalid userType');
      }
    }
  }
}
