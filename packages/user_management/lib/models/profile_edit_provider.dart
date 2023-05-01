import 'package:flutter/material.dart';

class ProfileEditProvider with ChangeNotifier {
  String? _phone;
  String? _name;
  String? _email;
  String? _city;
  String? _address;
  double? _lat;
  double? _lng;
  String? _specs;

  String? get phone => _phone;
  String? get name => _name;
  String? get email => _email;
  String? get city => _city;
  String? get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;
  String? get specs => _specs;

  set savePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  set saveName(String value) {
    _name = value;
    notifyListeners();
  }

  set saveEmail(String value) {
    _email = value;
    notifyListeners();
  }

  set saveCity(String value) {
    _city = value;
    notifyListeners();
  }

  set saveAddress(String value) {
    _address = value;
    notifyListeners();
  }

  set saveLat(double value) {
    _lat = value;
    notifyListeners();
  }

  set saveLng(double value) {
    _lng = value;
    notifyListeners();
  }

  set saveSpecs(String value) {
    _specs = value;
    notifyListeners();
  }

  void clearFormInputs() {
    _phone = null;
    _name = null;
    _email = null;
    _city = null;
    _address = null;
    _lat = null;
    _lng = null;
    _specs = null;
    notifyListeners();
  }
}
