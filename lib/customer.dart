import 'dart:convert';
import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:service/models/service_request_manager.dart';

class Customer extends User {
  String? id;
  Map<String, dynamic>? customerData;

  Customer({String? phone, String? name, String? email})
      : super(phone: phone, name: name, email: email);

  void mapRegisterData() {
    customerData = {
      'phoneNumber': phone,
      'name': name,
      'email': email,
    };
  }

  Future<void> saveCustomerData() async {
    Database firestore = Database();
    id = await firestore.addCustomerData(customerData!);
    await pushNoti.obtainDeviceToken();
    pushNoti.saveDeviceToken(id!);
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
      List<String> timeSlotList) async {
    List<bool> availResult = [false, false, false, false];

    Database firestore = Database();
    for (int i = 0; i < timeSlotList.length; i++) {
      bool avail = await firestore.checkTechnicianAvailability(
          serviceCategory, city, date, timeSlotList[i], matchedQty);

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
  Future<void> login(BuildContext context, String phoneNumber) async {
    await retrieveLoginData(phoneNumber);

    Map<String, dynamic> customerData = {
      'id': id,
      'name': name,
    };

    if (context.mounted) {
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

  @override
  Future<void> retrieveLoginData(String phoneNumber) async {
    final customerDoc = await Database.getCustomerByPhoneNumber(phoneNumber);
    if (customerDoc.exists) {
      id = customerDoc.id;
      name = customerDoc.data()!['name'];
    }
  }
}
