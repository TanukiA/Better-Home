import 'package:authentication/models/customer.dart';
import 'package:map/models/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';

class LocationController extends ControllerMVC {
  late Location _location;
  late Firestore _db;

  Location get location => _location;

  LocationController() {
    _location = Location();
  }
}
