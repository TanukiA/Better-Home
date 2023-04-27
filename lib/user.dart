import 'package:authentication/models/registration_form_provider.dart';
import 'package:authentication/views/first_screen.dart';
import 'package:better_home/customer.dart';
import 'package:better_home/technician.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';

abstract class User extends ModelMVC {
  String? phone;
  String? name;
  String? email;
  // Notification notification;
  // Location address;

  User({required this.phone, required this.name, required this.email});

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
            Map<String, dynamic> customerData = customer.mapRegisterData();
            Database firestore = Database();
            firestore.addCustomerData(customerData);
            customer.login(context, phoneNumber);
          } else if (userType == "technician" && purpose == "login") {
            Technician technician = Technician(
                address: '',
                city: '',
                exp: '',
                lat: 0.0,
                lng: 0.0,
                specs: [],
                pickedFile: PlatformFile(name: '', size: 0));
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
            );
            fp.clearFormInputs();
            technician.mapRegisterData();
            technician.saveTechnicianData(context);
            technician.goToLoginScreen(context);
          }
        });
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
