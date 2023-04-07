import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/views/technician_signup_screen2.dart';
import 'package:flutter/material.dart';
import 'package:map/models/map_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';
import 'package:better_home/utils.dart';

class LocationController extends ControllerMVC {
  late MapService _map;
  late Database _db;

  MapService get map => _map;
  LocationController() {
    _map = MapService();
  }

  Future<void> handleSearchButton(
      BuildContext context,
      GlobalKey<ScaffoldState> homeScaffoldKey,
      DisplayPredictionCallback displayPredictionCallback) {
    return _map.handleSearchButton(
        context, homeScaffoldKey, displayPredictionCallback);
  }

  Future<void> handleConfirmButton(
      BuildContext context,
      String? selectedAddress,
      double? lat,
      double? lng,
      FormInputProvider provider) async {
    if (selectedAddress != null && lat != null && lng != null) {
      provider.saveAddress = selectedAddress;
      provider.saveLat = lat;
      provider.saveLng = lng;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TechnicianSignupScreen2(
                  controller: RegistrationController("technician"),
                )),
      );
    } else {
      showSnackBar(context, 'Please select an address');
    }
  }

  String getApiKey() {
    return _map.kGoogleApiKey;
  }
}
