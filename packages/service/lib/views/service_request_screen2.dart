import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:better_home/text_field_container.dart';

class ServiceRequestScreen2 extends StatefulWidget {
  const ServiceRequestScreen2(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;
  @override
  StateMVC<ServiceRequestScreen2> createState() =>
      _ServiceRequestScreen2State();
}

class _ServiceRequestScreen2State extends StateMVC<ServiceRequestScreen2> {
  String? _selectedVariation;
  late TextEditingController _descriptionController;

  @override
  initState() {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestFormProvider>(context);

    return ChangeNotifierProvider<ServiceRequestFormProvider>.value(
      value: provider,
      child: Consumer<ServiceRequestFormProvider>(
        builder: (context, obtainedData, _) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedVariation,
                  items: [
                    ...<String>[
                      'Kuala Lumpur / Selangor',
                      'Putrajaya',
                      'Johor',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ],
                  onChanged: (newValue) {},
                  hint: _selectedVariation == null
                      ? const Text("Select service variation")
                      : null,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  dropdownColor: Colors.white,
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Describe your issue and request:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFieldContainer(
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    //provider.saveExp = value;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
