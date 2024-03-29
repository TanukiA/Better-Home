import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/registration_form_provider.dart';
import 'package:authentication/views/technician_signup_screen2.dart';
import 'package:flutter/material.dart';
import 'package:map/models/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home/utils.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/views/service_request_form.dart';
import 'package:user_management/controllers/user_controller.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:user_management/views/edit_profile_screen.dart';

class LocationController extends ControllerMVC {
  late Location _map;

  Location get map => _map;

  LocationController() {
    _map = Location();
  }

  Future<void> handleSearchButton(
      BuildContext context,
      GlobalKey<ScaffoldState> homeScaffoldKey,
      DisplayPredictionCallback displayPredictionCallback) async {
    return await _map.handleSearchButton(
        context, homeScaffoldKey, displayPredictionCallback);
  }

  Future<void> handleConfirmButton1(BuildContext context,
      String? selectedAddress, double? lat, double? lng) async {
    if (selectedAddress != null && lat != null && lng != null) {
      final provider =
          Provider.of<RegistrationFormProvider>(context, listen: false);
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

  Future<void> handleConfirmButton2(BuildContext context,
      String? selectedAddress, double? lat, double? lng) async {
    if (selectedAddress != null && lat != null && lng != null) {
      final provider =
          Provider.of<ServiceRequestFormProvider>(context, listen: false);
      provider.saveAddress = selectedAddress;
      provider.saveLat = lat;
      provider.saveLng = lng;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ServiceRequestForm(
                  serviceCategory: provider.serviceCategory!,
                  serviceType: provider.serviceType!,
                  cusController: CustomerController(),
                  serviceController: ServiceController(),
                )),
      );
    } else {
      showSnackBar(context, 'Please select an address');
    }
  }

  Future<void> handleConfirmButton3(
      BuildContext context,
      String? selectedAddress,
      double? lat,
      double? lng,
      String userType) async {
    if (selectedAddress != null && lat != null && lng != null) {
      final provider = Provider.of<ProfileEditProvider>(context, listen: false);
      provider.saveAddress = selectedAddress;
      provider.saveLat = lat;
      provider.saveLng = lng;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(
            controller: UserController(userType),
            userType: userType,
          ),
        ),
      );
    } else {
      showSnackBar(context, 'Please select an address');
    }
  }

  String getApiKey() {
    return _map.kGoogleApiKey;
  }
}
