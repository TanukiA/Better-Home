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

class Customer extends User {
  String? _id;

  Customer({String? phone, String? name, String? email})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final customerDoc = await Database.getCustomerByPhoneNumber(phoneNumber);

    if (customerDoc.exists) {
      _id = customerDoc.id;
      name = customerDoc['name'];
      email = customerDoc['email'];
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

  Future<Map<String, dynamic>> retrieveServiceDescription(
      String serviceTitle) async {
    final jsonString =
        await rootBundle.loadString('assets/serviceDescription.json');
    Map<String, dynamic> data = jsonDecode(jsonString);

    return data[serviceTitle];
  }

  @override
  void login(BuildContext context, String phoneNumber) {
    retrieveLoginData(phoneNumber);

    Map<String, dynamic> customerData = {
      'id': _id,
      'phoneNumber': phone,
      'name': name,
      'email': email,
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
