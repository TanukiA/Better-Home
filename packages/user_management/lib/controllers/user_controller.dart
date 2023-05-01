import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:file_picker/file_picker.dart';
import 'package:user_management/views/edit_profile_screen.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:provider/provider.dart';

class UserController extends ControllerMVC {
  late User _user;

  User get user => _user;

  UserController(String userType) {
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
  }

  Future<DocumentSnapshot> retrieveProfileData(
      String userType, BuildContext context) async {
    return _user.retrieveProfileData(userType, context);
  }

  void handleEditIcon(
      String userType, Map<String, dynamic> profileData, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          controller: UserController(userType),
          userType: userType,
        ),
      ),
    );
  }

  void saveProfileToProvider(
      BuildContext context,
      Map<String, dynamic> profileData,
      String userType,
      String specializationStr) {
    final provider = Provider.of<ProfileEditProvider>(context, listen: false);
    provider.saveName = profileData["name"];
    provider.saveEmail = profileData["email"];
    provider.savePhone = profileData["phoneNumber"];
    if (userType == "technician") {
      provider.saveSpecs = specializationStr;
      provider.saveCity = profileData["city"];
      provider.saveAddress = profileData["address"];
    }
  }

  void verifyPhoneNumberUpdate(
      BuildContext context,
      String userOTP,
      String verificationId,
      String userType,
      String purpose,
      String phoneNumber) {
    /*
    return _user.verifyPhoneNumberUpdate(
        context, userOTP, verificationId, userType, purpose, phoneNumber);*/
  }
}
