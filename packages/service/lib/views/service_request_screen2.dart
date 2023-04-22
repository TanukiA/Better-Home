import 'dart:io';
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
  String? _selectedPropertyType;
  List<String> _serviceVariationList = [];
  late TextEditingController _descriptionController;

  @override
  initState() {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    super.initState();
    setServiceVariationList();
    provider.variation != null
        ? _selectedVariation = provider.variation
        : _selectedVariation = null;
    _descriptionController = TextEditingController(text: provider.description);
    provider.propertyType != null
        ? _selectedPropertyType = provider.propertyType
        : _selectedPropertyType = null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void setServiceVariationList() async {
    _serviceVariationList = await widget.controller
        .retrieveServiceVariations(widget.serviceCategory, widget.serviceType);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestFormProvider>(context);

    final ButtonStyle filePickBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    );

    return ChangeNotifierProvider<ServiceRequestFormProvider>.value(
      value: provider,
      child: Consumer<ServiceRequestFormProvider>(
        builder: (context, obtainedData, _) {
          return Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Service variation:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
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
                    items: _serviceVariationList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      _selectedVariation = newValue;
                      provider.saveVariation = newValue!;
                    },
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
              ),
              const SizedBox(height: 15),
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
                  maxLines: 7,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    provider.saveDescription = value;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Property type:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
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
                    value: _selectedPropertyType,
                    items: [
                      ...<String>[
                        "Landed",
                        "Flat/Apartment",
                        "Condo/Serviced Residence",
                        "Shophouse",
                        "Others"
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                    onChanged: (newValue) {
                      _selectedPropertyType = newValue;
                      provider.savePropertyType = newValue!;
                    },
                    hint: _selectedPropertyType == null
                        ? const Text("Select your property type")
                        : null,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upload photo(s) to show your issue (optional):',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.controller.pickImages(context, provider),
                  style: filePickBtnStyle,
                  child: const Text('Select file'),
                ),
              ),
              const SizedBox(height: 10),
              provider.imgFiles != null
                  ? Wrap(
                      children: provider.imgFiles!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final imageone = entry.value;
                        return Card(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  widget.controller
                                      .removeImage(index, provider);
                                }),
                                child: SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: Image.file(File(imageone.path)),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    widget.controller
                                        .removeImage(index, provider);
                                  }),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Container(),
              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
