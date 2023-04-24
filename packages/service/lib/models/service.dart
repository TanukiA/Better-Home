import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:service/models/payment.dart';
import 'package:service/models/technician_assigner.dart';

class Service extends ModelMVC {
  late Payment _payment;
  late TechnicianAssigner _techAssigner;

  Service() {
    _payment = Payment();
  }

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

  void processServiceRequest(int price) async {
    //await _payment.makePayment(price);
    //await _payment.displayPaymentSheet();
    print("DONE PAYMENT, going to technician assign");
    _techAssigner = TechnicianAssigner(_payment.context!);
    _techAssigner.pickSuitableTechnician();
  }

  void saveServiceRequest() {}
}
