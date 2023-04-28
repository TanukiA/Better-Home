import 'package:better_home/technician.dart';
import 'package:better_home/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

class TechnicianController extends ControllerMVC {
  late Technician _tech;

  Technician get cus => _tech;

  TechnicianController() {
    _tech = Technician(
        address: '',
        city: '',
        exp: '',
        lat: 0.0,
        lng: 0.0,
        specs: [],
        pickedFile: PlatformFile(name: '', size: 0));
  }

  Future<List<QueryDocumentSnapshot>> retrieveAssignedServices(
      BuildContext context) {
    return _tech.readAssignedServices(context);
  }

  String formatToLocalDate(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  void acceptIconPressed(QueryDocumentSnapshot serviceDoc) {
    String id = serviceDoc.id;
    Timestamp date =
        (serviceDoc.data() as Map<String, dynamic>)["assignedDate"];
    String timeSlot =
        (serviceDoc.data() as Map<String, dynamic>)["assignedTime"];

    final timeFormat = DateFormat.jm();
    final start = timeFormat.parse(timeSlot.split(' - ')[0]);
    final end = timeFormat.parse(timeSlot.split(' - ')[1]);

    final startTime = DateTime(date.toDate().year, date.toDate().month,
        date.toDate().day, start.hour, start.minute);
    final endTime = DateTime(date.toDate().year, date.toDate().month,
        date.toDate().day, end.hour, end.minute);

    _tech.acceptRequest(serviceDoc, startTime, endTime);
  }
}
