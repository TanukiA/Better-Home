import 'package:firebase_data/models/database.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class Notification extends ModelMVC {
  late Database db;
  String serviceID;
  DateTime dateTime;
  String notiMessage;
  String readStatus;

  Notification({
    required this.serviceID,
    required this.dateTime,
    required this.notiMessage,
    required this.readStatus,
  }) {
    db = Database();
  }
}
