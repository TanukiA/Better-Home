import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:better_home/text_field_container.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;
  @override
  StateMVC<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends StateMVC<PaymentScreen> {
  late TextEditingController _descriptionController;

  @override
  initState() {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    super.initState();
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
            children: [],
          );
        },
      ),
    );
  }
}
