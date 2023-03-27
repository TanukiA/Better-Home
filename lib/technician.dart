import 'package:authentication/models/form_input_provider.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
  String? fileName;

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
      PlatformFile? pickedFile,
      String? fileName = ""})
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

  Map<String, dynamic> getRegisterDataFromProvider(BuildContext context) {
    final provider = Provider.of<FormInputProvider>(context, listen: false);
    phone = provider.phone;
    name = provider.name;
    email = provider.email;
    specs = provider.specs;
    exp = provider.exp;
    city = provider.city;
    address = provider.address;
    lat = provider.lat;
    lng = provider.lng;
    pickedFile = provider.pickedFile;
    fileName = provider.fileName;

    LatLng location = LatLng(lat!, lng!);
    GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);

    Technician technician = Technician(
        phone: phone!.trim(),
        name: name!.trim(),
        email: email!.trim(),
        specs: specs,
        exp: exp!.trim(),
        city: city,
        address: address!.trim(),
        lat: lat,
        lng: lng,
        pickedFile: pickedFile,
        fileName: fileName);
    Map<String, dynamic> technicainData = {
      'phoneNumber': technician.phone,
      'name': technician.name,
      'email': technician.email,
      'specs': technician.specs,
      'exp': technician.exp,
      'city': technician.city,
      'address': technician.address,
      'lat': technician.lat,
      'lng': technician.lng,
      'pickedFile': technician.pickedFile,
      'fileName': technician.fileName
    };
    return technicainData;
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
    ap.storeUserDataToSP(technicianData, "technician_session_data");
    ap.setTechnicianSignIn();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()));
  }
}
