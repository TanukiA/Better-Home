import 'package:authentication/models/form_input_provider.dart';
import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';
import 'package:provider/provider.dart';

class RegistrationController extends ControllerMVC {
  late User _user;
  late Database _db;
  List<String> specs = [];

  User get user => _user;

  RegistrationController(String userType) {
    if (userType == 'technician') {
      _user = Technician(
          address: '',
          city: '',
          exp: '',
          lat: 0.0,
          lng: 0.0,
          specs: [],
          pickedFile: PlatformFile(name: '', size: 0));
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

  bool validEmailFormat(String email) {
    return User.validEmailFormat(email);
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

  bool checkValidForm(bool isValid1, bool isValid2, bool isValid3) {
    if (isValid1 && isValid2 && isValid3) {
      return true;
    } else {
      return false;
    }
  }

  bool checkValidTechnicianForm(
      bool isValid1, bool isValid2, bool isValid3, bool isValid4) {
    if (isValid1 && isValid2 && isValid3 && isValid4) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isAccountExists(String phoneNumber, String userType) async {
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }

  void saveCustomerDataToProvider(
      BuildContext context, String phoneNumber, String name, String email) {
    final provider = Provider.of<FormInputProvider>(context);
    provider.savePhone = phoneNumber;
    provider.saveName = name;
    provider.saveEmail = email;
  }

  void checkboxStateChange(List<bool> checkboxValues, int i, String specName,
      FormInputProvider provider) {
    if (checkboxValues[i] && !specs.contains(specName)) {
      specs.add(specName);
    } else if (!checkboxValues[i] && specs.contains(specName)) {
      specs.remove(specName);
    }
    provider.updateCheckboxValue(i, checkboxValues[i]);
    provider.saveSpecs = specs;
  }
}
