import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:better_home/technician.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:file_picker/file_picker.dart';
import 'package:service/models/service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

class TechnicianController extends ControllerMVC {
  late Technician _tech;
  late Service _service;

  Technician get cus => _tech;

  TechnicianController() {
    _tech = Technician(
        address: '',
        city: '',
        exp: '',
        lat: 0.0,
        lng: 0.0,
        specs: [],
        pickedFile: PlatformFile(name: '', size: 0),
        dateTimeRegistered: DateTime(2023));
    _service = Service();
  }

  Future<List<QueryDocumentSnapshot>> retrieveAssignedServices(
      BuildContext context) {
    return _tech.readAssignedServices(context);
  }

  String formatToLocalDate(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<void> acceptIconPressed(
      QueryDocumentSnapshot serviceDoc, BuildContext context) async {
    String id = serviceDoc.id;
    final temp = (serviceDoc.data() as Map<String, dynamic>)["assignedDate"]
        .toDate()
        .toLocal();
    final appointmentDate = DateTime(temp.year, temp.month, temp.day);
    String appointmentTime =
        (serviceDoc.data() as Map<String, dynamic>)["assignedTime"];

    final technicianID =
        (serviceDoc.data() as Map<String, dynamic>)["technicianID"];
    final customerID =
        (serviceDoc.data() as Map<String, dynamic>)["customerID"];
    final serviceName =
        (serviceDoc.data() as Map<String, dynamic>)["serviceName"];

    await _tech.acceptRequest(id, appointmentDate, appointmentTime,
        technicianID, customerID, serviceName, context);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Service confirmed!"),
            content: const Text(
                "You can check your service in 'Work Schedules' tab in Services."),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TechnicianHomeScreen(
                        loginCon: LoginController("technician"),
                        techCon: TechnicianController(),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> rejectIconPressed(
      QueryDocumentSnapshot serviceDoc, BuildContext context) async {
    String technicianID =
        (serviceDoc.data() as Map<String, dynamic>)["technicianID"];
    final preferredDateTmpStp =
        (serviceDoc.data() as Map<String, dynamic>)["preferredDate"];
    final alternativeDateTmpStp =
        (serviceDoc.data() as Map<String, dynamic>)["alternativeDate"];
    final preferredTime =
        (serviceDoc.data() as Map<String, dynamic>)["preferredTime"];
    final alternativeTime =
        (serviceDoc.data() as Map<String, dynamic>)["alternativeTime"];

    final preferredDate = preferredDateTmpStp.toDate().toLocal();
    final alternativeDate = alternativeDateTmpStp.toDate().toLocal();
    final newPreferredDate =
        DateTime(preferredDate.year, preferredDate.month, preferredDate.day);
    final newAlternativeDate = DateTime(
        alternativeDate.year, alternativeDate.month, alternativeDate.day);

    final serviceName =
        (serviceDoc.data() as Map<String, dynamic>)["serviceName"];
    String serviceCategory = serviceName.split(" - ")[0];
    final city = (serviceDoc.data() as Map<String, dynamic>)["city"];
    final location = (serviceDoc.data() as Map<String, dynamic>)["location"];
    Database firestore = Database();

    String? technicianFromPreferred;
    String? technicianFromAlternative;

    // Look for technician using preferred appointment
    if (context.mounted) {
      technicianFromPreferred = await _service.processTechnicianReassign(
          context,
          serviceCategory,
          city,
          location,
          technicianID,
          newPreferredDate,
          preferredTime);
    }
    // If not found for preferred appointment, look for technician using alternative appointment
    if (technicianFromPreferred == null || technicianFromPreferred == "") {
      if (context.mounted) {
        technicianFromAlternative = await _service.processTechnicianReassign(
            context,
            serviceCategory,
            city,
            location,
            technicianID,
            newAlternativeDate,
            alternativeTime);
      }
      if (technicianFromAlternative == null ||
          technicianFromAlternative == "") {
        // Cancel service if not found in alternative appointment
        if (context.mounted) {
          firestore.updateCancelledStatus(serviceDoc.id, false, context);
        }
      }
    }

    if (technicianFromPreferred != null && technicianFromPreferred != "") {
      // Assign new technician to replace current one
      // Update assignedDate and assignedTime using preferredAppointment

      firestore.updateTechnicianReassigned(serviceDoc.id,
          technicianFromPreferred, newPreferredDate, preferredTime);
    } else if (technicianFromAlternative != null &&
        technicianFromAlternative != "") {
      // Assign new technician to replace current one
      // Update assignedDate and assignedTime using alternativeAppointment
      firestore.updateTechnicianReassigned(serviceDoc.id,
          technicianFromAlternative, newAlternativeDate, alternativeTime);
    }
  }

  Future<List<Map<String, dynamic>?>> retrieveReviews(
      BuildContext context) async {
    return await _tech.retrieveReviews(context);
  }

  double retrieveAvgRating() {
    return _tech.retrieveAvgRating();
  }
}
