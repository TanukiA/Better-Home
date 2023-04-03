import 'package:authentication/models/form_input_provider.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Technician extends User {
  String? id;
  List<String>? specs;
  String? exp;
  String? city;
  String? address;
  double? lat;
  double? lng;
  PlatformFile? pickedFile;
  Map<String, dynamic>? technicianData;

  Technician(
      {String phone = "",
      String name = "",
      String email = "",
      List<String>? specs = const [],
      String? exp = "",
      String? city = "",
      String? address = "",
      double? lat = 0.0,
      double? lng = 0.0,
      PlatformFile? pickedFile})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final technicianDoc =
        await Database.getTechnicianByPhoneNumber(phoneNumber);

    if (technicianDoc.exists) {
      id = technicianDoc.id;
      name = technicianDoc['name'];
      email = technicianDoc['email'];
      phone = technicianDoc['phoneNumber'];
    }
  }

  void mapRegisterData() {
    LatLng location = LatLng(lat!, lng!);
    GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);

    technicianData = {
      'phoneNumber': phone,
      'name': name,
      'email': email,
      'specialization': specs,
      'experience': exp,
      'city': city,
      'address': address,
      'location': geoPoint,
      'approvalStatus': false,
    };
  }

  void saveTechnicianData(BuildContext context) {
    Database firestore = Database();
    final provider = Provider.of<FormInputProvider>(context, listen: false);
    firestore.addTechnicianData(technicianData!, provider);
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
    ap.setTechnicianSignIn();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()));
  }
}
