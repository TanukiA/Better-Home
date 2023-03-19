import 'package:authentication/models/customer.dart';
import 'package:authentication/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';

class LocationController extends ControllerMVC {
  late User _user;
  late Firestore _db;

  User get user => _user;

  LocationController() {
    _user = Customer();
  }
}
