import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RegistrationFormProvider with ChangeNotifier {
  String? _phone;
  String? _name;
  String? _email;
  List<String>? _specs;
  String? _exp;
  String? _city;
  String? _address;
  double? _lat;
  double? _lng;
  PlatformFile? _pickedFile;
  String? _fileName;
  final List<bool> _checkboxValues = [false, false, false, false, false, false];

  String? get phone => _phone;
  String? get name => _name;
  String? get email => _email;
  List<String>? get specs => _specs;
  String? get exp => _exp;
  String? get city => _city;
  String? get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;
  PlatformFile? get pickedFile => _pickedFile;
  String? get fileName => _fileName;
  List<bool>? get checkboxValues => _checkboxValues;

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

  set saveSpecs(List<String> value) {
    _specs = value;
    notifyListeners();
  }

  set saveExp(String value) {
    _exp = value;
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

  set savePickedFile(PlatformFile value) {
    _pickedFile = value;
    notifyListeners();
  }

  set saveFileName(String value) {
    _fileName = value;
    notifyListeners();
  }

  void updateCheckboxValue(int index, bool value) {
    _checkboxValues[index] = value;
    notifyListeners();
  }

  void clearFormInputs() {
    _phone = null;
    _name = null;
    _email = null;
    _specs = null;
    _exp = null;
    _city = null;
    _address = null;
    _lat = null;
    _lng = null;
    _pickedFile = null;
    _fileName = null;
    _checkboxValues.fillRange(0, _checkboxValues.length, false);
    notifyListeners();
  }
}
