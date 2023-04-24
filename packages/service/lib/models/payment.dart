import 'dart:convert';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;

class Payment extends ModelMVC {
  Map<String, dynamic>? _paymentIntentData;
  static BuildContext? _context;

  BuildContext? get context => _context;

  Payment() {
    Stripe.publishableKey =
        'pk_test_51MzjMXBaKsiCNQU8rVcgJfQxlnLm30Wrr10tL3lZoXC65o4T8FGejooPFWRuC8QYvHfiJu1iqmiZZebJLWA7VH4N00UYYMpPSr';
  }

  Future<void> makePayment(int amount) async {
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
      showSnackBar(_context!, e.toString());
    }

    setState(() {});
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((paymentResult) {
        setState(() {
          // end payment
          _paymentIntentData = null;
        });
      });
    } on StripeException catch (e) {
      showSnackBar(_context!, e.toString());
    } catch (e) {
      showSnackBar(_context!, e.toString());
    }
  }

  void setBuildContext(BuildContext value) {
    _context = value;
  }
}
