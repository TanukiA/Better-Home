import 'package:better_home/customer.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/customer_controller.dart';

class ServiceRequestForm1 extends StatefulWidget {
  const ServiceRequestForm1(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;

  @override
  StateMVC<ServiceRequestForm1> createState() => _ServiceRequestFormState1();
}

class _ServiceRequestFormState1 extends StateMVC<ServiceRequestForm1> {
  late Customer _cus;
  //bool isLoading = true;

  @override
  initState() {
    _cus = widget.controller.cus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.serviceType,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        leading: const BackButton(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(
          size: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
