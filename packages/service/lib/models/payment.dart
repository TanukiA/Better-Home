import 'dart:convert';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:service/models/service.dart';

class Payment extends ModelMVC {
  Map<String, dynamic>? _paymentIntentData;
  static BuildContext? context;

  Payment() {
    Stripe.publishableKey =
        'pk_test_51MzjMXBaKsiCNQU8rVcgJfQxlnLm30Wrr10tL3lZoXC65o4T8FGejooPFWRuC8QYvHfiJu1iqmiZZebJLWA7VH4N00UYYMpPSr';
  }

  Future<void> preparePayment(int amount) async {
    final url = Uri.parse(
        'https://us-central1-better-home-a2dbf.cloudfunctions.net/stripePayment?amount=$amount');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      _paymentIntentData = json.decode(response.body);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'BetterHome',
        paymentIntentClientSecret: _paymentIntentData!['paymentIntent'],
        style: ThemeMode.dark,
      ));
    } catch (e) {
      showSnackBar(context!, e.toString());
    }

    setState(() {});
  }

  Future<void> makePayment() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((paymentResult) {
        Service.updatePaymentSuccess(true);
        setState(() {
          // end payment
          _paymentIntentData = null;
        });
      });
    } on StripeException catch (e) {
      showSnackBar(context!, e.toString());
    } catch (e) {
      showSnackBar(context!, e.toString());
    }
  }

  void setBuildContext(BuildContext value) {
    context = value;
  }
}
