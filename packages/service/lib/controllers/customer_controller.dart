import 'package:better_home/customer.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:service/views/service_category_screen.dart';
import 'package:service/views/service_descript_screen.dart';

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
}
