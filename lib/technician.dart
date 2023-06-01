import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_data/models/database.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:user_management/models/rating.dart';

class Technician extends User {
  final Rating _rating;
  String? id;
  List<String>? specs;
  String? exp;
  String? city;
  String? address;
  double? lat;
  double? lng;
  DateTime? dateTimeRegistered;
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
      required DateTime this.dateTimeRegistered,
      required PlatformFile this.pickedFile})
      : _rating = Rating(),
        super(phone: phone, name: name, email: email);

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
      'dateTimeRegistered': DateTime.now(),
    };
  }

  Future<void> saveTechnicianData() async {
    Database firestore = Database();
    id = await firestore.addTechnicianData(technicianData!, pickedFile!);
    await pushNoti.obtainDeviceToken();
    pushNoti.saveDeviceToken(id!);
  }

  void goToLoginScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text(
              "You have signed up successfully. Kindly wait for approval."),
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

  Future<List<QueryDocumentSnapshot>> readAssignedServices(
      BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    return await firestore.readAssignedServices(id);
  }

  Future<void> acceptRequest(
      String serviceID,
      DateTime appointmentDate,
      String appointmentTime,
      String technicianID,
      String customerID,
      String serviceName,
      BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String technicianName = await ap.getUserNameFromSP("session_data");

    Database firestore = Database();
    if (context.mounted) {
      await firestore.updateAcceptRequest(
          serviceID, customerID, serviceName, technicianName, context);
    }
    await firestore.addWorkSchedule(
        serviceID, appointmentDate, appointmentTime, technicianID);
  }

  Future<List<Map<String, dynamic>?>> retrieveReviews(
      BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String technicianID = await ap.getUserIDFromSP("session_data");
    await _rating.getReviewsForTechnician(technicianID);
    return _rating.reviewData;
  }

  double retrieveAvgRating() {
    return _rating.avgStarQty;
  }

  @override
  Future<void> login(BuildContext context, String phoneNumber) async {
    await retrieveLoginData(phoneNumber);
    Map<String, dynamic> technicianData = {
      'id': id,
      'name': name,
    };

    if (context.mounted) {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      ap.storeUserDataToSP(technicianData, "session_data");
      ap.setTechnicianSignIn();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TechnicianHomeScreen(
                    loginCon: LoginController("technician"),
                    techCon: TechnicianController(),
                  )));
    }
  }

  @override
  Future<void> retrieveLoginData(String phoneNumber) async {
    final technicianDoc =
        await Database.getTechnicianByPhoneNumber(phoneNumber);

    if (technicianDoc.exists) {
      id = technicianDoc.id;
      name = technicianDoc.data()!['name'];
    }
  }
}
