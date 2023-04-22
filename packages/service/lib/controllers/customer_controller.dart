import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:better_home/customer.dart';
import 'package:better_home/utils.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/views/service_category_screen.dart';
import 'package:service/views/service_descript_screen.dart';
import 'package:service/views/service_request_form.dart';
import 'package:firebase_db/models/database.dart';
import 'package:intl/intl.dart';
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
      List<String> timeStartStr = ['10:00AM', '1:00PM', '3:00PM', '5:00PM'];
      List<String> timeEndStr = ['12:00PM', '3:00PM', '5:00PM', '7:00PM'];
      final timeFormat = DateFormat('h:mma');
      final timeStartList = timeStartStr
          .map((timeString) => timeFormat.parse(timeString))
          .toList();
      final timeEndList =
          timeEndStr.map((timeString) => timeFormat.parse(timeString)).toList();

      return _cus.retrieveTechnicianAvailability(
          serviceCategory, city, date, matchedQty, timeStartList, timeEndList);
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
    final serviceVariations =
        await _cus.retrieveServiceVariations(serviceTitle);
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

  bool validateServiceRequestInput(ServiceRequestFormProvider provider) {
    if (provider.city == null || provider.city!.isEmpty) {
      return false;
    }
    if (provider.address == null || provider.address!.isEmpty) {
      return false;
    }
    if (provider.lat == null) {
      return false;
    }
    if (provider.lng == null) {
      return false;
    }
    if (provider.preferredDate == null) {
      return false;
    }
    if (provider.preferredTimeSlot == null ||
        provider.preferredTimeSlot!.isEmpty) {
      return false;
    }
    if (provider.alternativeDate == null) {
      return false;
    }
    if (provider.alternativeTimeSlot == null ||
        provider.alternativeTimeSlot!.isEmpty) {
      return false;
    }
    if (provider.variation == null || provider.variation!.isEmpty) {
      return false;
    }
    if (provider.description == null || provider.description!.isEmpty) {
      return false;
    }
    if (provider.propertyType == null || provider.propertyType!.isEmpty) {
      return false;
    }

    if (!validDateAndTime(provider.preferredDate, provider.preferredTimeSlot,
        provider.alternativeDate, provider.alternativeTimeSlot)) {
      return false;
    }
    return true;
  }

  void handleCancelForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancel this order?"),
          content: const Text("Your progress will be discarded."),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerHomeScreen(
                      loginCon: LoginController("customer"),
                      cusCon: CustomerController(),
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
