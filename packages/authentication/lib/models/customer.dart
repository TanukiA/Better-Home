import 'package:authentication/models/user.dart';
import 'package:firebase_db/models/database.dart';

class Customer extends User {
  final String phone;
  final String name;
  final String email;

  Customer({required this.phone, required this.name, required this.email})
      : super(phone: phone, name: name, email: email);

  void register() {}

  @override
  void login() {}

  @override
  void logout() {}
}
