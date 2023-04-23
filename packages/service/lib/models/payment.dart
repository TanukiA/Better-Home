import 'dart:convert';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;

class Payment extends ModelMVC {
  Map<String, dynamic>? _paymentIntentData;
  BuildContext? _context;

  Payment() {
    Stripe.publishableKey =
        'pk_test_51MzjMXBaKsiCNQU8rVcgJfQxlnLm30Wrr10tL3lZoXC65o4T8FGejooPFWRuC8QYvHfiJu1iqmiZZebJLWA7VH4N00UYYMpPSr';
  }

  Future<void> makePayment(String amount) async {

    final url = Uri.parse(
        'https://us-central1-better-home-a2dbf.cloudfunctions.net/stripePayment?amount=$amount');

    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    _paymentIntentData = json.decode(response.body);

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
      merchantDisplayName: 'BetterHome',
      paymentIntentClientSecret: _paymentIntentData!['paymentIntent'],
      style: ThemeMode.dark,
    ));

    setState(() {});

    displayPaymentSheet();
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        showSnackBar(_context!, "Paid successfully");
        setState(() {
          // end payment
          _paymentIntentData = null;
        });
      }).onError((e, stackTrace) {
        print('Exception: $e $stackTrace');
        showSnackBar(_context!, e.toString());
      });
      /*
      setState(() {
        // end payment
        paymentIntentData = null;
      });*/
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showSnackBar(_context!, e.toString());
    } catch (e) {
      showSnackBar(_context!, e.toString());
      print(e);
    }
  }

  void setBuildContext(BuildContext context) {
    _context = context;
  }
}
