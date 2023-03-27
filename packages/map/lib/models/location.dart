import 'package:firebase_db/models/database.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

class MapLocation extends ModelMVC {
  final double latitude;
  final double longitude;
  final String address;

  MapLocation(this.latitude, this.longitude, this.address);
}
