import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ServiceRequestFormProvider with ChangeNotifier {
  String? _serviceCategory;
  String? _serviceType;
  String? _city;
  String? _address;
  double? _lat;
  double? _lng;
  DateTime? _preferredDate;
  String? _preferredTimeSlot;
  DateTime? _alternativeDate;
  String? _alternativeTimeSlot;
  String? _variation;
  String? _description;
  String? _propertyType;
  PlatformFile? _pickedFile;
  String? _fileName;

  String? get serviceCategory => _serviceCategory;
  String? get serviceType => _serviceType;
  String? get city => _city;
  String? get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;
  DateTime? get preferredDate => _preferredDate;
  String? get preferredTimeSlot => _preferredTimeSlot;
  DateTime? get alternativeDate => _alternativeDate;
  String? get alternativeTimeSlot => _alternativeTimeSlot;
  String? get variation => _variation;
  String? get description => _description;
  String? get propertyType => _propertyType;
  PlatformFile? get pickedFile => _pickedFile;
  String? get fileName => _fileName;

  set saveServiceCategory(String value) {
    _serviceCategory = value;
    notifyListeners();
  }

  set saveServiceType(String value) {
    _serviceType = value;
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

  set savePreferredDate(DateTime value) {
    _preferredDate = value;
    notifyListeners();
  }

  set savePreferredTimeSlot(String value) {
    _preferredTimeSlot = value;
    notifyListeners();
  }

  set saveAlternativeDate(DateTime value) {
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
    _serviceCategory = null;
    _serviceType = null;
    _city = null;
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
