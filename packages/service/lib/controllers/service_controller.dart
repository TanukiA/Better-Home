import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:better_home/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/payment.dart';
import 'package:service/models/service.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:firebase_data/models/database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
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
      return DateFormat('dd-MM-yyyy').format(date);
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

  Future<List<QueryDocumentSnapshot<Object?>>> retrieveActiveServicesData(
      BuildContext context) {
    return _service.retrieveActiveServicesData(context);
  }

  String formatToLocalDate(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String formatToLocalDateTime(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  DateTime dateInDateTime(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return dateTime;
  }

  Future<List<Widget>> retrieveServiceImages(QueryDocumentSnapshot serviceDoc) {
    Database db = Database();
    return db.downloadServiceImages(serviceDoc);
  }

  Future<String> retrieveTechnicianName(QueryDocumentSnapshot serviceDoc) {
    return _service.retrieveTechnicianName(serviceDoc);
  }

  Future<List<QueryDocumentSnapshot<Object?>>> retrievePastServicesData(
      BuildContext context, String idType) {
    return _service.retrievePastServicesData(context, idType);
  }

  Future<Map<String, dynamic>> retrieveServiceRating(
      QueryDocumentSnapshot serviceDoc) {
    return _service.retrieveServiceRating(serviceDoc.id);
  }

  // Assigning - allow cancel
  // In Progress - reject cancel
  // Confirmed - if current time is at least 12 hours before appointment time, allow cancel
  void handleCancelService(QueryDocumentSnapshot serviceDoc,
      BuildContext context, String technicianID) {
    if ((serviceDoc.data() as Map<String, dynamic>)["serviceStatus"] ==
        "Assigning") {
      _service.cancelService(serviceDoc.id, context, technicianID);
    } else if ((serviceDoc.data() as Map<String, dynamic>)["serviceStatus"] ==
        "In Progress") {
      showDialogBox(
          context, "You can't cancel", "The service is already in progress.");
    } else if ((serviceDoc.data() as Map<String, dynamic>)["serviceStatus"] ==
        "Confirmed") {
      if (_service.validTimeToCancel(serviceDoc)) {
        _service.cancelService(serviceDoc.id, context, technicianID);
      } else {
        showDialogBox(context, "You can't cancel",
            "Cancellation is allowed up until 12 hours before your appointment.");
      }
    }
  }

  Future<void> submitReview(double starQty, String reviewText,
      QueryDocumentSnapshot serviceDoc) async {
    String customerID =
        (serviceDoc.data() as Map<String, dynamic>)["customerID"];
    String technicianID =
        (serviceDoc.data() as Map<String, dynamic>)["technicianID"];
    await _service.saveNewReview(
        starQty, reviewText, serviceDoc.id, customerID, technicianID);
  }

  Future<String> retrieveCustomerName(QueryDocumentSnapshot serviceDoc) {
    return _service.retrieveCustomerName(serviceDoc);
  }

  Future<List<QueryDocumentSnapshot<Object?>>> retrieveWorkScheduleData(
      BuildContext context) {
    return _service.retrieveWorkScheduleData(context);
  }

  Future<void> handleServiceStatusUpdate(String id, String newStatus) async {
    return _service.saveNewStatus(id, newStatus);
  }
}
