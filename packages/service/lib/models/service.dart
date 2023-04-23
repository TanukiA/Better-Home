import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:service/models/payment.dart';

class Service extends ModelMVC {
  late Payment _payment;

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

  void processServiceRequest(int price) {
    _payment.makePayment(price);
    // calculate shortest distance using Map
  }

  void saveServiceRequest() {}
}
