import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db/models/database.dart';

class Technician extends User {
  final String phone;
  final String name;
  final String email;

  Technician({required this.phone, required this.name, required this.email})
      : super(phone: phone, name: name, email: email);

  @override
  void login(BuildContext context, String phoneNumber) {}

  @override
  void logout() {}
}
