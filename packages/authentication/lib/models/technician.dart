import 'package:authentication/models/user.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class Technician extends User {
  String? id;
  List<String>? specs;
  String? exp;
  String? address;
  String? latLong;
  PlatformFile? pickedFile;

  Technician(
      {String phone = "",
      String name = "",
      String email = "",
      List<String>? specs = const [],
      String? exp = "",
      String? address = "",
      String? latLong = "",
      PlatformFile? pickedFile})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final technicianDoc =
        await Firestore.getTechnicianByPhoneNumber(phoneNumber);

    if (technicianDoc.exists) {
      id = technicianDoc.id;
      name = technicianDoc['name'];
      email = technicianDoc['email'];
      phone = technicianDoc['phoneNumber'];
    }
  }

  @override
  void login(BuildContext context, String phoneNumber) {
    retrieveLoginData(phoneNumber);

    Map<String, dynamic> technicianData = {
      'id': id,
      'phoneNumber': phone,
      'name': name,
      'email': email,
    };
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeUserDataToSP(technicianData, "session_data");
    ap.setSignIn();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()));
  }

  @override
  void logout() {}
}
