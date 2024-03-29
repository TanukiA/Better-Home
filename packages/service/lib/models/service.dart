import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/payment.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/models/technician_assigner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:service/views/customer_service_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class Service extends ModelMVC {
  late Payment _payment;
  late TechnicianAssigner _techAssigner;
  Map<String, dynamic>? _serviceRequestData;
  List<QueryDocumentSnapshot> _servicesDoc = [];
  static bool paymentSuccess = false;

  Service() {
    _payment = Payment();
  }

  List<QueryDocumentSnapshot> get servicesDoc => _servicesDoc;

  Future<int> loadServicePrice(String serviceTitle, String variation) async {
    final jsonString =
        await rootBundle.loadString('assets/serviceVariations.json');
    final jsonData = json.decode(jsonString);

    final service = jsonData['services']
        .firstWhere((service) => service['title'] == serviceTitle);

    final issue =
        service['issues'].firstWhere((issue) => issue['name'] == variation);

    return issue['price'];
  }

  void processServiceRequest(int price, BuildContext context) async {
    paymentSuccess = false;
    await _payment.preparePayment(price);
    await _payment.makePayment();

    if (paymentSuccess) {
      _techAssigner = TechnicianAssigner(Payment.context!);
      await _techAssigner.pickSuitableTechnician();

      final ap = Provider.of<AuthProvider>(Payment.context!, listen: false);
      final provider = Provider.of<ServiceRequestFormProvider>(Payment.context!,
          listen: false);
      String id = await ap.getUserIDFromSP("session_data");
      final servicePrice = price / 100;

      _serviceRequestData = {
        'dateTimeSubmitted': DateTime.now(),
        'serviceStatus': 'Assigning',
        'customerID': id,
        'technicianID': _techAssigner.nearestTechnicianID,
        'address': provider.address,
        'location': _techAssigner.serviceLocation,
        'city': provider.city,
        'payment': servicePrice,
        'serviceName': '${provider.serviceCategory} - ${provider.serviceType}',
        'serviceVariation': provider.variation,
        'propertyType': provider.propertyType,
        'description': provider.description,
        'preferredDate': provider.preferredDate,
        'preferredTime': provider.preferredTimeSlot,
        'alternativeDate': provider.alternativeDate,
        'alternativeTime': provider.alternativeTimeSlot,
        'assignedDate': provider.preferredDate,
        'assignedTime': provider.preferredTimeSlot,
      };
      if (context.mounted) {
        saveServiceRequest(provider.imgFiles, context);
      }
    }
  }

  void saveServiceRequest(List<XFile>? imgFiles, BuildContext context) {
    Database firestore = Database();
    firestore.storeServiceRequest(_serviceRequestData!, imgFiles, context);
    showDialog(
      context: Payment.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text(
              "Your service request has been submitted. Kindly wait for confirmation."),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
              onPressed: () {
                final provider = Provider.of<ServiceRequestFormProvider>(
                    context,
                    listen: false);
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

  static void updatePaymentSuccess(bool newValue) {
    paymentSuccess = newValue;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> retrieveActiveServicesData(
      BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    _servicesDoc = await firestore.readActiveServices(id);
    return servicesDoc;
  }

  Future<String> retrieveTechnicianName(
      QueryDocumentSnapshot serviceDoc) async {
    Database firestore = Database();
    String technicianName = await firestore.readTechnicianName(serviceDoc);
    return technicianName;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> retrievePastServicesData(
      BuildContext context, String idType) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    _servicesDoc = await firestore.readPastServices(id, idType);
    return servicesDoc;
  }

  Future<Map<String, dynamic>> retrieveServiceRating(String id) async {
    Database firestore = Database();
    final result = await firestore.readServiceRating(id);
    return result;
  }

  bool validTimeToCancel(QueryDocumentSnapshot serviceDoc) {
    final confirmedDate =
        (serviceDoc.data() as Map<String, dynamic>)["confirmedDate"];
    final confirmedTime =
        (serviceDoc.data() as Map<String, dynamic>)["confirmedTime"];
    tzdata.initializeTimeZones();
    final location = tz.getLocation('Asia/Kuala_Lumpur');
    final currentTime = tz.TZDateTime.now(location);

    final startTimeStr = confirmedTime.split(" ")[0];
    final startTime = DateFormat('h:mma').parse(startTimeStr);

    final newConfirmedDate = DateTime.fromMillisecondsSinceEpoch(
        confirmedDate.millisecondsSinceEpoch);

    // Create a new DateTime object with the values from confirmedDate and the starting time of confirmedTime
    final confirmedAppointment = DateTime(
      newConfirmedDate.year,
      newConfirmedDate.month,
      newConfirmedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final isAtLeast12HoursBefore =
        confirmedAppointment.difference(currentTime).inHours.abs() >= 12;

    return isAtLeast12HoursBefore;
  }

  void cancelService(String serviceID, BuildContext context,
      [String technicianID = ""]) {
    Database firestore = Database();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Cancel this service?"),
            content: const Text("You cannot undo after cancelling service."),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Yes"),
                onPressed: () async {
                  await firestore.updateServiceCancelled(
                      serviceID, context, technicianID);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CustomerServiceScreen(initialIndex: 0),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> saveNewReview(double starQty, String? reviewText, String id,
      String customerID, String technicianID) async {
    Database firestore = Database();
    await firestore.storeServiceReview(
        starQty, reviewText, id, customerID, technicianID);
  }

  Future<String> retrieveCustomerName(QueryDocumentSnapshot serviceDoc) async {
    Database firestore = Database();
    String customerName = await firestore.readCustomerName(serviceDoc);
    return customerName;
  }

  Future<String?> processTechnicianReassign(
      BuildContext context,
      String serviceCategory,
      String city,
      GeoPoint location,
      String technicianID,
      DateTime date,
      String timeSlot) async {
    Database firestore = Database();
    await firestore.appendUnavailableTechnician(
        serviceCategory, city, date, timeSlot, technicianID);

    String? nearestTechnicianID;

    if (context.mounted) {
      _techAssigner = TechnicianAssigner(context);
    }
    nearestTechnicianID = await _techAssigner.pickReassignTechnician(
        serviceCategory, city, location);

    return nearestTechnicianID;
  }

  Future<List<QueryDocumentSnapshot<Object?>>> retrieveWorkScheduleData(
      BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String id = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    _servicesDoc = await firestore.readWorkData(id);

    _servicesDoc.sort((a, b) {
      final String timeA = (a.data() as Map<String, dynamic>)['confirmedTime'];
      final String timeB = (b.data() as Map<String, dynamic>)['confirmedTime'];
      // Parse the time strings into DateTime objects
      final DateTime dateTimeA =
          DateFormat('h:mma').parse(timeA.split('-')[0].trim());
      final DateTime dateTimeB =
          DateFormat('h:mma').parse(timeB.split('-')[0].trim());

      // Convert DateTime objects to a comparable format (24-hour format)
      final String comparableTimeA = DateFormat('HH:mm').format(dateTimeA);
      final String comparableTimeB = DateFormat('HH:mm').format(dateTimeB);

      // Compare the comparable time strings
      return comparableTimeA.compareTo(comparableTimeB);
    });
    return servicesDoc;
  }

  Future<void> saveNewStatus(
      String id, String newStatus, BuildContext context) async {
    Database firestore = Database();
    await firestore.updateServiceStatus(id, newStatus, context);
  }
}
