import 'package:better_home/customer.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/views/service_category_screen.dart';
import 'package:service/views/service_descript_screen.dart';
import 'package:service/views/service_request_form.dart';
import 'package:firebase_db/models/database.dart';

class CustomerController extends ControllerMVC {
  late Customer _cus;
  List<String> services = [];

  Customer get cus => _cus;

  CustomerController() {
    _cus = Customer();
  }

  void setServiceCategoryScreen(String serviceCategory, BuildContext context) {
    if (serviceCategory == "Plumbing") {
      services = [
        "Leakage Repair",
        "Drainage Service",
        "Water Heater Repair / Install",
        "Toilet Repair / Install"
      ];
    } else if (serviceCategory == "Aircon Servicing") {
      services = ["Aircon Repair / Install", "Aircon Cleaning & Inspection"];
    } else if (serviceCategory == "Roof Servicing") {
      services = ["Leakage Repair", "Shingle/Tile Replacement"];
    } else if (serviceCategory == "Electrical & Wiring") {
      services = [
        "Ceiling Fan Install",
        "Light Fixture Install",
        "Extend Wiring/Plug Points",
        "Electrical Safety Inspection"
      ];
    } else if (serviceCategory == "Window & Door") {
      services = ["Window Repair / Replacement", "Foor Repair / Replacement"];
    } else if (serviceCategory == "Painting") {
      services = [
        "Interior Painting",
        "Exterior Painting",
        "Wallpaper Removal"
      ];
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceCategoryScreen(
            serviceCategory: serviceCategory,
            services: services,
            controller: CustomerController(),
          ),
        ));
  }

  void setServiceDescriptionScreen(
      String serviceCategory, String serviceType, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDescriptionScreen(
            serviceCategory: serviceCategory,
            serviceType: serviceType,
            controller: CustomerController(),
          ),
        ));
  }

  Future<Map<String, dynamic>> retrieveServiceDescription(
      String serviceCategory, String serviceType) async {
    String serviceTitle = "$serviceCategory - $serviceType";
    final descripTexts = await _cus.retrieveServiceDescription(serviceTitle);
    return descripTexts;
  }

  List<String> retrieveExplanations(Map<String, dynamic> descripTexts) {
    return List<String>.from(descripTexts['explanations']);
  }

  String retrievePriceRange(Map<String, dynamic> descripTexts) {
    return descripTexts['priceRange'];
  }

  String retrieveImgPath(Map<String, dynamic> descripTexts) {
    return descripTexts['img'];
  }

  void setServiceRequestForm(
      String serviceCategory, String serviceType, BuildContext context) {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    provider.saveServiceCategory = serviceCategory;
    provider.saveServiceType = serviceType;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceRequestForm(
            serviceCategory: serviceCategory,
            serviceType: serviceType,
            controller: CustomerController(),
          ),
        ));
  }

  Future<List<bool>> retrieveTechnicianAvailability(
      String serviceCategory, String city, DateTime date) async {
    Database firestore = Database();
    int matchedQty =
        await firestore.getTechnicianQtyMatched(serviceCategory, city);
    print("serviceCategory: $serviceCategory");
    print("city: $city");
    print("matchedQty: $matchedQty");
    if (matchedQty == 0) {
      Future<List<bool>> result = Future.value([false, false, false, false]);
      return result;
    } else {
      return _cus.retrieveTechnicianAvailability(
          serviceCategory, city, date, matchedQty);
    }
  }

  bool validDateAndTime(DateTime? preferredDate, String? preferredTimeSlot,
      DateTime? alternativeDate, String? alternativeTimeSlot) {
    if (preferredDate == null ||
        preferredTimeSlot == null ||
        alternativeDate == null ||
        alternativeTimeSlot == null) {
      return true;
    }

    if ((preferredDate == alternativeDate) &&
        (preferredTimeSlot == alternativeTimeSlot)) {
      return false;
    }
    return true;
  }
}
