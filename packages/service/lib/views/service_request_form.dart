import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:service/views/payment_screen.dart';
import 'package:service/views/service_request_screen1.dart';
import 'package:service/views/service_request_screen2.dart';

class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.cusController,
      required this.serviceController})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController cusController;
  final ServiceController serviceController;

  @override
  StateMVC<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends StateMVC<ServiceRequestForm> {
  int _activeStepIndex = 0;

  @override
  initState() {
    super.initState();
  }

  List<Step> stepList() => [
        Step(
          state: StepState.editing,
          isActive: _activeStepIndex >= 0,
          title: const Text('Appointment'),
          content: ServiceRequestScreen1(
            serviceCategory: widget.serviceCategory,
            serviceType: widget.serviceType,
            controller: widget.cusController,
          ),
        ),
        Step(
          state: StepState.editing,
          isActive: _activeStepIndex >= 1,
          title: const Text('Details'),
          content: ServiceRequestScreen2(
            serviceCategory: widget.serviceCategory,
            serviceType: widget.serviceType,
            controller: widget.cusController,
          ),
        ),
        Step(
          state: StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: const Text('Pay'),
          content: PaymentScreen(
            serviceCategory: widget.serviceCategory,
            serviceType: widget.serviceType,
            controller: widget.serviceController,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestFormProvider>(context);
    Size size = MediaQuery.of(context).size;

    setState(() {
      widget.serviceController.passBuildContext(context);
    });

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
          leading: IconButton(
            icon: const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              widget.serviceController.handleCancelForm(context, provider);
            },
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
              bool isValid = true;

              // Validate user input of service request form
              if (_activeStepIndex == 1) {
                isValid = widget.serviceController
                    .validateServiceRequestInput(provider);
              }

              if (isValid) {
                if (_activeStepIndex < (stepList().length - 1)) {
                  setState(() {
                    _activeStepIndex += 1;
                  });
                }
              } else {
                showDialogBox(context, "Empty field found",
                    "Please fill up all the required fields.");
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
                        style: btnStyle,
                        child: const Text('Back'),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isLastStep)
                          ? () => widget.serviceController.submitRequest()
                          : controlDetails.onStepContinue,
                      style: btnStyle,
                      child:
                          (isLastStep) ? const Text('Pay') : const Text('Next'),
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
