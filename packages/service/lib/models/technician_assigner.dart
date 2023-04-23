import 'package:better_home/technician.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:map/models/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/models/service_request_form_provider.dart';

class TechnicianAssigner extends ModelMVC {
  late Location _location;
  BuildContext? _context;
  List<Map<String, double>> coordinates = [];
  List<Map<String, dynamic>> techniciansMap = [];

  TechnicianAssigner(BuildContext context) {
    _context = context;
    _location = Location();
  }

  void pickSuitableTechnician() {
    Database firestore = Database();
    final provider =
        Provider.of<ServiceRequestFormProvider>(_context!, listen: false);
    techniciansMap = firestore.getLocationOfAvailableTechnician(
        provider.serviceCategory!, provider.city!);
    print("Technicians to be chosen 2: $techniciansMap");
    retrieveLocations();
  }

  void retrieveLocations() {
    List<dynamic> locations =
        techniciansMap.map((technician) => technician['location']).toList();
    print("Locations: $locations");
  }
}
