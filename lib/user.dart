import 'package:authentication/models/registration_form_provider.dart';
import 'package:authentication/views/first_screen.dart';
import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_data/models/database.dart';
import 'package:firebase_data/models/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:user_management/controllers/user_controller.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:user_management/views/profile_screen.dart';

abstract class User extends ModelMVC {
  String? phone;
  String? name;
  String? email;
  late PushNotification _pushNoti;

  User({required this.phone, required this.name, required this.email}) {
    _pushNoti = PushNotification();
  }

  PushNotification get pushNoti => _pushNoti;

  static bool validPhoneFormat(String phone) {
    if ((phone.startsWith('+60') &&
            (phone.length == 12 || phone.length == 13)) ||
        phone.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void sendPhoneNumber(BuildContext context, String phoneInput, String userType,
      String purpose) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneInput.trim();
    ap.signInWithPhone(context, phoneNumber, userType, purpose);
  }

  static bool validEmailFormat(String email) {
    if (email.isEmpty) return true;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  void verifyOTP(BuildContext context, String userOTP, String verificationId,
      String userType, String purpose, String phoneNumber) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOTP(
        context: context,
        verificationId: verificationId,
        userOTP: userOTP,
        onSuccess: () {
          if (userType == "customer" && purpose == "login") {
            Customer customer = Customer();
            customer.login(context, phoneNumber);
          } else if (userType == "customer" && purpose == "register") {
            final fp =
                Provider.of<RegistrationFormProvider>(context, listen: false);
            Customer customer = Customer(
                phone: fp.phone!.trim(),
                name: fp.name!.trim(),
                email: fp.email!.trim());
            fp.clearFormInputs();
            customer.mapRegisterData();
            customer.saveCustomerData();
            customer.login(context, phoneNumber);
          } else if (userType == "technician" && purpose == "login") {
            Technician technician = Technician(
                address: '',
                city: '',
                exp: '',
                lat: 0.0,
                lng: 0.0,
                specs: [],
                pickedFile: PlatformFile(name: '', size: 0),
                dateTimeRegistered: DateTime(2023));
            technician.login(context, phoneNumber);
          } else if (userType == "technician" && purpose == "register") {
            final fp =
                Provider.of<RegistrationFormProvider>(context, listen: false);
            Technician technician = Technician(
                phone: fp.phone!.trim(),
                name: fp.name!.trim(),
                email: fp.email!.trim(),
                specs: fp.specs!,
                exp: fp.exp!.trim(),
                city: fp.city!,
                address: fp.address!.trim(),
                lat: fp.lat!,
                lng: fp.lng!,
                pickedFile: fp.pickedFile != null
                    ? fp.pickedFile!
                    : PlatformFile(name: '', size: 0),
                dateTimeRegistered: DateTime(2023));
            fp.clearFormInputs();
            technician.mapRegisterData();
            technician.saveTechnicianData();
            technician.goToLoginScreen(context);
          }
        });
  }

  Future<DocumentSnapshot> retrieveProfileData(
      String userType, BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    final profileDoc = await firestore.readProfileData(userType, id);
    return profileDoc;
  }

  Future<void> saveProfileData(BuildContext context, String userType,
      ProfileEditProvider provider) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();

    if (userType == "technician") {
      LatLng location = LatLng(provider.lat!, provider.lng!);
      GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);
      await firestore.updateUserProfile(id, provider.name!, provider.email!,
          provider.city, provider.address, geoPoint, userType);
    } else {
      await firestore.updateUserProfile(
          id, provider.name!, provider.email!, "", "", null, userType);
    }
  }

  Future<bool> usedPhoneNumber(String phone, String userType) async {
    Database firestore = Database();
    String collectionName = '$userType' 's';
    final exist = await firestore.checkAccountExistence(phone, collectionName);
    return exist;
  }

  void verifyPhoneNumberUpdate(
      BuildContext context,
      String userOTP,
      String verificationId,
      String userType,
      String purpose,
      String phoneNumber,
      firebase_auth.User? currentUser) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyPhoneNumberUpdate(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
      onSuccess: () async {
        Database firestore = Database();
        final ap = Provider.of<AuthProvider>(context, listen: false);
        String id = await ap.getUserIDFromSP("session_data");
        await firestore.updatePhoneNumber(id, phoneNumber, userType);
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text(
                    "Your phone number has been updated successfully."),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            controller: UserController(userType),
                            userType: userType,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      currentUser: currentUser!,
    );
  }

  void logout(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.userSignOut().then(
          (value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FirstScreen(),
            ),
          ),
        );
  }

  void login(BuildContext context, String phoneNumber);

  Future<void> retrieveLoginData(String phoneNumber);
}
