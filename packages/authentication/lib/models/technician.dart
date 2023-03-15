import 'package:authentication/models/user.dart';
import 'package:firebase_db/models/database.dart';

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
  Future<void> isAccountExists(String phone) async {
    Firestore db = Firestore();
    final exist = await db.checkAccountExistence(phone, 'technicians');
  }

  @override
  void login() {}

  @override
  void logout() {}
}
