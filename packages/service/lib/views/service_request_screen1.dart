import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/models/service_request_form_provider.dart';
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
  String? _selectedCity;
  String? _selectedPreferredTime;
  String? _selectedAlternativeTime;
  bool isLoadingPreferred = false;
  bool isLoadingAlternative = false;

  late TextEditingController _addressController;
  late TextEditingController _preferredDateController;
  late TextEditingController _alternativeDateController;

  @override
  initState() {
    final provider =
        Provider.of<ServiceRequestFormProvider>(context, listen: false);
    super.initState();
    _addressController = TextEditingController(text: provider.address);
    _preferredDateController = TextEditingController(
        text: provider.preferredDate == null
            ? ""
            : DateFormat('dd-MM-yyyy').format(provider.preferredDate!));
    _alternativeDateController = TextEditingController(
        text: provider.alternativeDate == null
            ? ""
            : DateFormat('dd-MM-yyyy').format(provider.alternativeDate!));
    provider.city != null
        ? _selectedCity = provider.city
        : _selectedCity = null;
    provider.preferredTimeSlot != null
        ? _selectedPreferredTime = provider.preferredTimeSlot
        : _selectedPreferredTime = null;
    provider.alternativeTimeSlot != null
        ? _selectedAlternativeTime = provider.alternativeTimeSlot
        : _selectedAlternativeTime = null;
  }

  void handlePreferredDatePicked(ServiceRequestFormProvider provider) async {
    isLoadingPreferred = true;
    _selectedPreferredTime = null;
    provider.savePreferredTimeSlot = "";
    provider.saveAvailPreferredTime = await widget.controller
        .retrieveTechnicianAvailability(
            widget.serviceCategory, provider.city!, provider.preferredDate!);
    isLoadingPreferred = false;
    provider.saveIsPreferredDatePicked = true;
  }

  void handleAlternativeDatePicked(ServiceRequestFormProvider provider) async {
    isLoadingAlternative = true;
    _selectedAlternativeTime = null;
    provider.saveAlternativeTimeSlot = "";
    provider.saveAvailAlternativeTime = await widget.controller
        .retrieveTechnicianAvailability(
            widget.serviceCategory, provider.city!, provider.alternativeDate!);
    isLoadingAlternative = false;
    provider.saveIsAlternativeDatePicked = true;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _preferredDateController.dispose();
    _alternativeDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceRequestFormProvider>(context);

    Size size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<ServiceRequestFormProvider>.value(
      value: provider,
      child: Consumer<ServiceRequestFormProvider>(
          builder: (context, obtainedData, _) {
        return Column(
          children: [
            Row(
              children: [
                const Text(
                  'State:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
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
                    value: _selectedCity,
                    items: [
                      ...<String>[
                        'Kuala Lumpur / Selangor',
                        'Putrajaya',
                        'Johor',
                        'Kedah',
                        'Kelantan',
                        'Melaka',
                        'Negeri Sembilan',
                        'Pahang',
                        'Perak',
                        'Pulau Pinang'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                    onChanged: (newValue) {
                      _selectedCity = newValue;
                      provider.saveCity = newValue!;
                    },
                    hint: _selectedCity == null
                        ? const Text("Select your state")
                        : null,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
                            purpose: "service",
                          )),
                );
              },
              child: TextFieldContainer(
                child: TextFormField(
                  enabled: false,
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Pick service address',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Preferred appointment date:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                DateTime? initialDate = _preferredDateController.text.isNotEmpty
                    ? DateFormat('dd-MM-yyyy')
                        .parse(_preferredDateController.text)
                    : DateTime.now().add(const Duration(days: 1));

                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _preferredDateController.text =
                      DateFormat('dd-MM-yyyy').format(date);
                  provider.savePreferredDate = date;
                  setState(() {
                    handlePreferredDatePicked(provider);
                  });
                }
              },
              child: TextFieldContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        enabled: false,
                        controller: _preferredDateController,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Not selected yet',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime? initialDate =
                            _preferredDateController.text.isNotEmpty
                                ? DateFormat('dd-MM-yyyy')
                                    .parse(_preferredDateController.text)
                                : DateTime.now().add(const Duration(days: 1));

                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          _preferredDateController.text =
                              DateFormat('dd-MM-yyyy').format(date);
                          provider.savePreferredDate = date;
                          setState(() {
                            handlePreferredDatePicked(provider);
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Preferred time slot:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
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
                    child: Opacity(
                      opacity: provider.isPreferredDatePicked ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !provider.isPreferredDatePicked,
                        child: DropdownButton<String>(
                          value: _selectedPreferredTime,
                          items: provider.availPreferredTime
                                  .every((value) => !value)
                              ? [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text("No slot available"))
                                ]
                              : provider.availPreferredTime
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.value)
                                  .map((entry) {
                                  final index = entry.key;
                                  final value = <String>[
                                    '10:00AM - 12:00PM',
                                    '1:00PM - 3:00PM',
                                    '3:00PM - 5:00PM',
                                    '5:00PM - 7:00PM',
                                  ][index];
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          onChanged: (newValue) {
                            _selectedPreferredTime = newValue;
                            provider.savePreferredTimeSlot = newValue!;
                          },
                          hint: _selectedPreferredTime == null
                              ? const Text("Select preferred time slot")
                              : null,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  isLoadingPreferred == true
                      ? const CircularProgressIndicator(
                          color: Color.fromARGB(255, 51, 119, 54),
                        )
                      : Container(),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alternative appointment date:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                DateTime? initialDate =
                    _alternativeDateController.text.isNotEmpty
                        ? DateFormat('dd-MM-yyyy')
                            .parse(_alternativeDateController.text)
                        : DateTime.now().add(const Duration(days: 1));

                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _alternativeDateController.text =
                      DateFormat('dd-MM-yyyy').format(date);
                  provider.saveAlternativeDate = date;
                  setState(() {
                    handleAlternativeDatePicked(provider);
                  });
                }
              },
              child: TextFieldContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        enabled: false,
                        controller: _alternativeDateController,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Not selected yet',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime? initialDate =
                            _alternativeDateController.text.isNotEmpty
                                ? DateFormat('dd-MM-yyyy')
                                    .parse(_alternativeDateController.text)
                                : DateTime.now().add(const Duration(days: 1));

                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          _alternativeDateController.text =
                              DateFormat('dd-MM-yyyy').format(date);
                          provider.saveAlternativeDate = date;
                          setState(() {
                            handleAlternativeDatePicked(provider);
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alternative time slot:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
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
                    child: Opacity(
                      opacity: provider.isAlternativeDatePicked ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !provider.isAlternativeDatePicked,
                        child: DropdownButton<String>(
                          value: _selectedAlternativeTime,
                          items: provider.availAlternativeTime
                                  .every((value) => !value)
                              ? [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text("No slot available"))
                                ]
                              : provider.availAlternativeTime
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.value)
                                  .map((entry) {
                                  final index = entry.key;
                                  final value = <String>[
                                    '10:00AM - 12:00PM',
                                    '1:00PM - 3:00PM',
                                    '3:00PM - 5:00PM',
                                    '5:00PM - 7:00PM',
                                  ][index];
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          onChanged: (newValue) {
                            _selectedAlternativeTime = newValue;
                            provider.saveAlternativeTimeSlot = newValue!;
                          },
                          hint: _selectedAlternativeTime == null
                              ? const Text("Select alternative time slot")
                              : null,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  isLoadingAlternative == true
                      ? const CircularProgressIndicator(
                          color: Color.fromARGB(255, 51, 119, 54),
                        )
                      : Container(),
                ],
              ),
            ),
            if (widget.controller.validDateAndTime(
                    provider.preferredDate,
                    _selectedPreferredTime,
                    provider.alternativeDate,
                    _selectedAlternativeTime) ==
                false)
              SizedBox(
                width: size.width * 0.8,
                height: 32,
                child: const Text(
                  'Please set a different appointment time as your alternative',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 25),
          ],
        );
      }),
    );
  }
}
