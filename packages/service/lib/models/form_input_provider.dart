import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FormInputProvider with ChangeNotifier {
  String? _address;
  double? _lat;
  double? _lng;
  String? _preferredDate;
  String? _preferredTimeSlot;
  String? _alternativeDate;
  String? _alternativeTimeSlot;
  String? _variation;
  String? _description;
  String? _propertyType;
  PlatformFile? _pickedFile;
  String? _fileName;

  String? get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;
  String? get preferredDate => _preferredDate;
  String? get preferredTimeSlot => _preferredTimeSlot;
  String? get alternativeDate => _alternativeDate;
  String? get alternativeTimeSlot => _alternativeTimeSlot;
  String? get variation => _variation;
  String? get description => _description;
  String? get propertyType => _propertyType;
  PlatformFile? get pickedFile => _pickedFile;
  String? get fileName => _fileName;

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

  set savePreferredDate(String value) {
    _preferredDate = value;
    notifyListeners();
  }

  set savePreferredTimeSlot(String value) {
    _preferredTimeSlot = value;
    notifyListeners();
  }

  set saveAlternativeDate(String value) {
    _alternativeDate = value;
    notifyListeners();
  }

  set saveAlternativeTimeSlot(String value) {
    _alternativeTimeSlot = value;
    notifyListeners();
  }

  set saveVariation(String value) {
    _variation = value;
    notifyListeners();
  }

  set saveDescription(String value) {
    _description = value;
    notifyListeners();
  }

  set savePropertyType(String value) {
    _propertyType = value;
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

  void clearFormInputs() {
    _address = null;
    _lat = null;
    _lng = null;
    _preferredDate = null;
    _preferredTimeSlot = null;
    _alternativeDate = null;
    _alternativeTimeSlot = null;
    _variation = null;
    _description = null;
    _propertyType = null;
    _pickedFile = null;
    _fileName = null;
    notifyListeners();
  }
}
