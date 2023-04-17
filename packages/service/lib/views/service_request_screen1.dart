import 'package:better_home/customer.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/serviceRequestForm_provider.dart';
import 'package:better_home/text_field_container.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';
import 'package:intl/intl.dart';

class ServiceRequestScreen1 extends StatefulWidget {
  const ServiceRequestScreen1(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;
  @override
  StateMVC<ServiceRequestScreen1> createState() =>
      _ServiceRequestScreen1State();
}

class _ServiceRequestScreen1State extends StateMVC<ServiceRequestScreen1> {
  late TextEditingController _addressController;
  late TextEditingController _preferredDateController;
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();

  @override
  initState() {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    super.initState();
    _addressController = TextEditingController(text: provider.address);
    _preferredDateController =
        TextEditingController(text: provider.preferredDate);

    _addressController.addListener(() {
      setState(() {
        checkAddressField();
      });
    });
  }

  void checkAddressField() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Address:',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPlaceScreen(
                        controller: LocationController(),
                      )),
            );
          },
          child: TextFieldContainer(
            child: TextFormField(
              enabled: false,
              controller: _addressController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Pick your address here',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 48, 48, 48),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _preferredDateController,
          onTap: () async {
            DateTime? date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              _preferredDateController.text =
                  DateFormat('yyyy-MM-dd').format(date);
            }
          },
          decoration: const InputDecoration(
            labelText: 'Date',
            hintText: 'Select a date',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: email,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: pass,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
        ),
      ],
    );
  }
}
