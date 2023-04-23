import 'dart:convert';
import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:service/models/handle_services_json.dart';
import 'package:service/models/service.dart';

class Customer extends User {
  String? _id;
  //late Service service;

  Customer({String? phone, String? name, String? email})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final customerDoc = await Database.getCustomerByPhoneNumber(phoneNumber);

    if (customerDoc.exists) {
      _id = customerDoc.id;
      phone = customerDoc['phoneNumber'];
    }
  }

  Map<String, dynamic> mapRegisterData() {
    Map<String, dynamic> customerData = {
      'phoneNumber': phone,
      'name': name,
      'email': email,
    };
    return customerData;
  }

  Future<Map<String, dynamic>> loadServiceDescription(
      String serviceTitle) async {
    final jsonString =
        await rootBundle.loadString('assets/serviceDescription.json');
    Map<String, dynamic> data = jsonDecode(jsonString);

    return data[serviceTitle];
  }

  Future<List<bool>> retrieveTechnicianAvailability(
      String serviceCategory,
      String city,
      DateTime date,
      int matchedQty,
      List<DateTime> timeStartList,
      List<DateTime> timeEndList) async {
    List<bool> availResult = [false, false, false, false];

    Database firestore = Database();
    for (int i = 0; i < timeStartList.length; i++) {
      bool avail = await firestore.checkTechnicianAvailability(serviceCategory,
          city, date, timeStartList[i], timeEndList[i], matchedQty);

      availResult[i] = avail;
    }

    return availResult;
  }

  Future<List<String>> loadServiceVariations(String serviceTitle) async {
    final jsonString =
        await rootBundle.loadString('assets/serviceVariations.json');

    final List<ServiceVariation> services =
        (json.decode(jsonString)['services'] as List)
            .map((category) => ServiceVariation.fromJson(category))
            .toList();

    ServiceVariation currentTitle =
        services.firstWhere((sp) => sp.title == serviceTitle);

    return currentTitle.issues.map((issue) => issue.name).toList();
  }

  @override
  void login(BuildContext context, String phoneNumber) {
    retrieveLoginData(phoneNumber);

    Map<String, dynamic> customerData = {
      'id': _id,
      'phoneNumber': phone,
    };
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeUserDataToSP(customerData, "session_data");
    ap.setCustomerSignIn();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CustomerHomeScreen(
                  loginCon: LoginController("customer"),
                  cusCon: CustomerController(),
                )));
  }
}
