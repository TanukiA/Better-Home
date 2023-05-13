import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:better_home/user.dart';
import 'package:better_home/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:file_picker/file_picker.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:user_management/views/edit_phone_screen.dart';
import 'package:user_management/views/edit_profile_screen.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:provider/provider.dart';
import 'package:user_management/views/profile_screen.dart';
import 'package:user_management/views/review_screen.dart';

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
      String? specializationStr) {
    final provider = Provider.of<ProfileEditProvider>(context, listen: false);
    provider.saveName = profileData["name"];
    provider.saveEmail = profileData["email"];
    provider.savePhone = profileData["phoneNumber"];

    if (userType == "technician") {
      provider.saveSpecs = specializationStr!;
      provider.saveCity = profileData["city"];
      provider.saveAddress = profileData["address"];
      final point = profileData["location"];
      provider.saveLat = point.latitude;
      provider.saveLng = point.longitude;
    }
  }

  Future<void> handleSaveIcon(BuildContext context, String userType,
      ProfileEditProvider provider) async {
    if (provider.name == "" ||
        provider.email == "" ||
        (userType == "technician" &&
            (provider.city == "" ||
                provider.address == "" ||
                provider.lat == null ||
                provider.lng == null))) {
      showDialogBox(
          context, "Empty field found", "Please fill up all the fields.");
    } else {
      await _user.saveProfileData(context, userType, provider);
      provider.clearFormInputs();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              controller: UserController(userType),
              userType: userType,
            ),
          ),
        );
      }
    }
  }

  void changePhoneNumber(BuildContext context, String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhoneScreen(
          controller: UserController(userType),
          userType: userType,
        ),
      ),
    );
  }

  bool validPhoneFormat(String phone) {
    return User.validPhoneFormat(phone);
  }

  Future<bool> usedPhoneNumber(String phone, String userType) {
    return _user.usedPhoneNumber(phone, userType);
  }

  void sendPhoneNumber(BuildContext context, String phoneInput, String userType,
      String purpose) {
    return _user.sendPhoneNumber(context, phoneInput.trim(), userType, purpose);
  }

  void verifyPhoneNumberUpdate(
      BuildContext context,
      String userOTP,
      String verificationId,
      String userType,
      String purpose,
      String phoneNumber,
      firebase_auth.User? currentUser) {
    _user.verifyPhoneNumberUpdate(context, userOTP, verificationId, userType,
        purpose, phoneNumber, currentUser!);
  }

  void pushToReviewScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          controller: TechnicianController(),
        ),
      ),
    );
  }
}
