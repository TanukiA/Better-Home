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
  late TextEditingController _addressController;
  late TextEditingController _preferredDateController;
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  int _activeStepIndex = 0;

  @override
  initState() {
    _cus = widget.controller.cus;
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

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Appointment'),
          content: Column(
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
          ),
        ),
        Step(
            state:
                _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
            isActive: _activeStepIndex >= 1,
            title: const Text('Details'),
            content: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: address,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Full House Address',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: pincode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pin Code',
                  ),
                ),
              ],
            )),
        Step(
            state: StepState.complete,
            isActive: _activeStepIndex >= 2,
            title: const Text('Confirm'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Email: ${email.text}'),
                const Text('Password: *****'),
                Text('Address : ${address.text}'),
                Text('PinCode : ${pincode.text}'),
              ],
            ))
      ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = Provider.of<ServiceRequestFormProvider>(context);

    return ChangeNotifierProvider<ServiceRequestFormProvider>.value(
      value: provider,
      child: Consumer<ServiceRequestFormProvider>(
        builder: (context, obtainedData, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
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
              body: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.teal,
                  ),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _activeStepIndex,
                  steps: stepList(),
                  onStepContinue: () {
                    if (_activeStepIndex < (stepList().length - 1)) {
                      setState(() {
                        _activeStepIndex += 1;
                      });
                    } else {
                      print('Submited');
                    }
                  },
                  onStepCancel: () {
                    if (_activeStepIndex == 0) {
                      return;
                    }
                    setState(() {
                      _activeStepIndex -= 1;
                    });
                  },
                  onStepTapped: (int index) {
                    setState(() {
                      _activeStepIndex = index;
                    });
                  },
                  controlsBuilder: (context, ControlsDetails controlDetails) {
                    final isLastStep =
                        _activeStepIndex == stepList().length - 1;
                    return Row(
                      children: [
                        if (_activeStepIndex > 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controlDetails.onStepCancel,
                              child: const Text('Back'),
                            ),
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controlDetails.onStepContinue,
                            child: (isLastStep)
                                ? const Text('Submit')
                                : const Text('Next'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
