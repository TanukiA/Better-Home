import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/payment.dart';
import 'package:service/models/service.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:firebase_db/models/database.dart';
import 'package:intl/intl.dart';

class ServiceController extends ControllerMVC {
  late Service _service;
  late Payment _payment;
  late int _servicePrice;

  Service get service => _service;
  Payment get payment => _payment;

  ServiceController() {
    _service = Service();
    _payment = Payment();
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

  void handleCancelForm(
      BuildContext context, ServiceRequestFormProvider provider) {
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
                provider.clearFormInputs();
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

  String formatDateOnly(DateTime? date) {
    if (date != null) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
    return "";
  }

  Future<int> getServicePrice(
      String serviceCategory, String serviceType, String? variation) async {
    String serviceTitle = "$serviceCategory - $serviceType";
    if (variation != null) {
      _servicePrice = await _service.loadServicePrice(serviceTitle, variation);
      return _servicePrice;
    }
    return 0;
  }

  void passBuildContext(BuildContext context) {
    return _payment.setBuildContext(context);
  }

  void submitRequest() {
    int priceInCent = _servicePrice * 100;
    _service.processServiceRequest(priceInCent);
  }
}
