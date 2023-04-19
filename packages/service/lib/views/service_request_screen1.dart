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
  bool isPreferredDatePicked = false;
  bool isAlternativeDatePicked = false;

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
            : DateFormat('yyyy-MM-dd').format(provider.preferredDate!));
    _alternativeDateController = TextEditingController(
        text: provider.alternativeDate == null
            ? ""
            : DateFormat('yyyy-MM-dd').format(provider.alternativeDate!));
    provider.city != null
        ? _selectedCity = provider.city
        : _selectedCity = null;
    provider.preferredTimeSlot != null
        ? _selectedPreferredTime = provider.preferredTimeSlot
        : _selectedPreferredTime = null;
    provider.alternativeTimeSlot != null
        ? _selectedAlternativeTime = provider.alternativeTimeSlot
        : _selectedAlternativeTime = null;

    _preferredDateController.addListener(() {
      setState(() {});
    });

    _alternativeDateController.addListener(() {
      setState(() {});
    });
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
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Select your state',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
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
                        'Perlis',
                        'Pulau Pinang',
                        'Terengganu',
                        'Sabah',
                        'Sarawak'
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
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _preferredDateController.text =
                      DateFormat('yyyy-MM-dd').format(date);
                  provider.savePreferredDate = date;
                  setState(() {
                    isPreferredDatePicked = true;
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
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          _preferredDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                          provider.savePreferredDate = date;
                          setState(() {
                            isPreferredDatePicked = true;
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
                child: Opacity(
                  opacity: isPreferredDatePicked ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !isPreferredDatePicked,
                    child: DropdownButton<String>(
                      value: _selectedPreferredTime,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select preferred time slot',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ...<String>[
                          '10:00AM - 12:00PM',
                          '1:00PM - 3:00PM',
                          '3:00PM - 5:00PM',
                          '5:00PM - 7:00PM',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) {
                        _selectedPreferredTime = newValue;
                        provider.savePreferredTimeSlot = newValue!;
                      },
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      dropdownColor: Colors.white,
                    ),
                  ),
                ),
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
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _preferredDateController.text =
                      DateFormat('yyyy-MM-dd').format(date);
                  provider.saveAlternativeDate = date;
                  setState(() {
                    isAlternativeDatePicked = true;
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
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          _alternativeDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                          provider.saveAlternativeDate = date;
                          setState(() {
                            isAlternativeDatePicked = true;
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
                child: Opacity(
                  opacity: isAlternativeDatePicked ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !isAlternativeDatePicked,
                    child: DropdownButton<String>(
                      value: _selectedAlternativeTime,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select alternative time slot',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ...<String>[
                          '10:00AM - 12:00PM',
                          '1:00PM - 3:00PM',
                          '3:00PM - 5:00PM',
                          '5:00PM - 7:00PM',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) {
                        _selectedAlternativeTime = newValue;
                        provider.saveAlternativeTimeSlot = newValue!;
                      },
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      dropdownColor: Colors.white,
                    ),
                  ),
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
