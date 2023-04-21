import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/login_screen.dart';
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
  String? _id;
  List<String>? specs;
  String? exp;
  String? city;
  String? address;
  double? lat;
  double? lng;
  PlatformFile? pickedFile;
  Map<String, dynamic>? technicianData;

  Technician(
      {String? phone,
      String? name,
      String? email,
      required List<String> this.specs,
      required String this.exp,
      required String this.city,
      required String this.address,
      required double this.lat,
      required double this.lng,
      required PlatformFile this.pickedFile})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final technicianDoc =
        await Database.getTechnicianByPhoneNumber(phoneNumber);

    if (technicianDoc.exists) {
      _id = technicianDoc.id;
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
    firestore.addTechnicianData(technicianData!, pickedFile!);
  }

  void goToLoginScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("You have signed up successfully."),
          actions: [
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(
                              userType: "technician",
                              controller: LoginController("technician"),
                            )));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void login(BuildContext context, String phoneNumber) {
    retrieveLoginData(phoneNumber);

    Map<String, dynamic> technicianData = {
      'id': _id,
      'phoneNumber': phone,
    };
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeUserDataToSP(technicianData, "session_data");
    ap.setTechnicianSignIn();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()));
  }
}
