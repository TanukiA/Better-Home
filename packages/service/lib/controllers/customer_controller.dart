import 'package:better_home/customer.dart';
import 'package:better_home/utils.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/views/service_category_screen.dart';
import 'package:service/views/service_descript_screen.dart';
import 'package:service/views/service_request_form.dart';
import 'package:firebase_db/models/database.dart';
import 'package:image_picker/image_picker.dart';

class CustomerController extends ControllerMVC {
  late Customer _cus;
  List<String> services = [];
  final ImagePicker imgpicker = ImagePicker();

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
    final descripTexts = await _cus.loadServiceDescription(serviceTitle);
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
            cusController: CustomerController(),
            serviceController: ServiceController(),
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
      final newDate = DateTime(date.year, date.month, date.day);

      List<String> timeSlotList = [
        '10:00AM - 12:00PM',
        '1:00PM - 3:00PM',
        '3:00PM - 5:00PM',
        '5:00PM - 7:00PM'
      ];

      return _cus.retrieveTechnicianAvailability(
          serviceCategory, city, newDate, matchedQty, timeSlotList);
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

  Future<List<String>> retrieveServiceVariations(
      String serviceCategory, String serviceType) async {
    String serviceTitle = "$serviceCategory - $serviceType";
    final serviceVariations = await _cus.loadServiceVariations(serviceTitle);
    return serviceVariations;
  }

  void pickImages(
      BuildContext context, ServiceRequestFormProvider provider) async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();

      if (pickedfiles != null) {
        provider.saveImgFiles = pickedfiles;
        setState(() {});
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void removeImage(int index, ServiceRequestFormProvider provider) {
    provider.imgFiles!.removeAt(index);
  }
}
