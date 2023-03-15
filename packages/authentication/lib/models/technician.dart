import 'package:authentication/models/user.dart';

class Technician extends User {
  final String id;
  final String phone;
  final String name;
  final String email;

  Technician(
      {required this.id,
      required this.phone,
      required this.name,
      required this.email})
      : super(id: id, phone: phone, name: name, email: email);

  @override
  void checkAccountExistence() {}

  @override
  void login() {}

  @override
  void logout() {}
}
