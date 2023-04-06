import 'package:better_home/customer.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:service/views/service_category_screen.dart';

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
          ),
        ));
  }
}
