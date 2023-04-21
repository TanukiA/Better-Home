import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/views/service_request_screen1.dart';

class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;

  @override
  StateMVC<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends StateMVC<ServiceRequestForm> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  int _activeStepIndex = 0;

  @override
  initState() {
    super.initState();
  }

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Appointment'),
          content: ServiceRequestScreen1(
            serviceCategory: widget.serviceCategory,
            serviceType: widget.serviceType,
            controller: widget.controller,
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
            title: const Text('Pay'),
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

    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
    );

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
              final isLastStep = _activeStepIndex == stepList().length - 1;
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
                      style: btnStyle,
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
  }
}
