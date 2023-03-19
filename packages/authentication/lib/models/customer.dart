import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/models/user.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Customer extends User {
  String id = "";

  Customer({String phone = "", String name = "", String email = ""})
      : super(phone: phone, name: name, email: email);

  retrieveLoginData(String phoneNumber) async {
    final customerDoc = await Firestore.getCustomerByPhoneNumber(phoneNumber);

    if (customerDoc.exists) {
      id = customerDoc.id;
      name = customerDoc['name'];
      email = customerDoc['email'];
      phone = customerDoc['phoneNumber'];
    }
  }

  @override
  void login(BuildContext context, String phoneNumber) {
    retrieveLoginData(phoneNumber);

    Map<String, dynamic> customerData = {
      'id': id,
      'phoneNumber': phone,
      'name': name,
      'email': email,
    };
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.storeUserDataToSP(customerData, "session_data");
    ap.setSignIn();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()));
  }

  @override
  void logout() {}
}
