import 'dart:io';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/models/customer.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/models/technician.dart';
import 'package:authentication/models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';
import 'package:provider/provider.dart';

class RegistrationController extends ControllerMVC {
  late User _user;
  late Firestore _db;
  UploadTask? uploadTask;

  User get user => _user;

  RegistrationController() {
    _user = Customer();
  }

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  bool validEmailFormat(String email) {
    return User.validEmailFormat(email);
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
    _db = Firestore();
    String collectionName = '$userType' 's';
    final exist = await _db.checkAccountExistence(phoneNumber, collectionName);
    return exist;
  }

  void saveCustomerDataToSP(
      BuildContext context, String phoneNumber, String name, String email) {
    User customer = Customer(
        phone: phoneNumber.trim(), name: name.trim(), email: email.trim());
    Map<String, dynamic> customerData = {
      'phoneNumber': customer.phone,
      'name': customer.name,
      'email': customer.email,
    };
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeUserDataToSP(customerData, "register_data");
  }

  List<String> checkboxStateChange(List<bool> checkboxValues, int i,
      String specName, List<String> specs, FormInputProvider provider) {
    if (checkboxValues[i] && !specs.contains(specName)) {
      specs.add(specName);
    } else if (!checkboxValues[i] && specs.contains(specName)) {
      specs.remove(specName);
    }
    provider.formInput = Technician(
      name: provider.formInput.name,
      email: provider.formInput.email,
      phone: provider.formInput.phone,
      specs: specs,
      exp: provider.formInput.exp,
      city: provider.formInput.city,
      address: provider.formInput.address,
      latLong: provider.formInput.latLong,
      pickedFile: provider.formInput.pickedFile,
    );
    return specs;
  }

  Future uploadFile(PlatformFile? pickedFile) async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
  }
}
