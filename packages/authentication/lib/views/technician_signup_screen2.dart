import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:better_home/user.dart';
import 'package:better_home/text_field_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';
import 'package:provider/provider.dart';
import 'package:authentication/views/technician_signup_screen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TechnicianSignupScreen2 extends StatefulWidget {
  const TechnicianSignupScreen2({Key? key, required this.controller})
      : super(key: key);
  final RegistrationController controller;

  @override
  StateMVC<TechnicianSignupScreen2> createState() =>
      _TechnicianSignupScreen2State();
}

class _TechnicianSignupScreen2State extends StateMVC<TechnicianSignupScreen2> {
  bool _isValidSpec = false;
  bool _isValidExp = false;
  bool _isValidCity = false;
  bool _isValidAddress = false;
  bool _isAllValid = false;
  String? _selectedValue;
  PlatformFile? pickedFile;
  String fileName = "";
  late List<bool> _checkboxValues;

  late TextEditingController _expController;
  late TextEditingController _addressController;

  @override
  void initState() {
    final provider = Provider.of<FormInputProvider>(context, listen: false);
    super.initState();

    _checkboxValues = provider.checkboxValues!;
    _expController = TextEditingController(text: provider.exp);
    _addressController = TextEditingController(text: provider.address);
    provider.city != null
        ? _selectedValue = provider.city
        : _selectedValue = null;
    validateCheckbox();
    checkCitySelected();
    checkExpField();
    checkAddressField();

    _expController.addListener(() {
      setState(() {
        checkExpField();
      });
    });

    _addressController.addListener(() {
      setState(() {
        checkAddressField();
      });
    });
  }

  void checkExpField() {
    if (_expController.text.isNotEmpty) {
      _isValidExp = true;
      if (widget.controller.checkValidTechnicianForm(
          _isValidSpec, _isValidExp, _isValidCity, _isValidAddress)) {
        _isAllValid = true;
      }
    } else {
      _isValidExp = false;
      _isAllValid = false;
    }
  }

  void checkAddressField() {
    if (_addressController.text.isNotEmpty) {
      _isValidAddress = true;
      if (widget.controller.checkValidTechnicianForm(
          _isValidSpec, _isValidExp, _isValidCity, _isValidAddress)) {
        _isAllValid = true;
      }
    } else {
      _isValidAddress = false;
      _isAllValid = false;
    }
  }

  void checkCitySelected() {
    setState(() {
      _isValidCity =
          _selectedValue != null && _selectedValue != 'Select your state';
      if (_isValidCity) {
        if (widget.controller.checkValidTechnicianForm(
            _isValidSpec, _isValidExp, _isValidCity, _isValidAddress)) {
          _isAllValid = true;
        }
      }
    });
  }

  void validateCheckbox() {
    bool isAnyChecked = false;

    setState(() {
      for (bool value in _checkboxValues) {
        if (value) {
          isAnyChecked = true;
          break;
        }
      }

      _isValidSpec = isAnyChecked;
      if (!_isValidSpec) {
        _isAllValid = false;
      }
      if (widget.controller.checkValidTechnicianForm(
          _isValidSpec, _isValidExp, _isValidCity, _isValidAddress)) {
        _isAllValid = true;
      }
    });
  }

  Future selectFile(FormInputProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      fileName = pickedFile!.name;
    });
    provider.savePickedFile = pickedFile!;
    provider.saveFileName = fileName;
  }

  @override
  void dispose() {
    _expController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = Provider.of<FormInputProvider>(context);

    final ButtonStyle signupBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      disabledForegroundColor: Colors.white,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    final ButtonStyle filePickBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    );

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.green;
      }
      return Colors.white;
    }

    MaterialStateProperty<Color?> backgroundColor =
        MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey;
        }
        return Colors.black;
      },
    );

    return ChangeNotifierProvider<FormInputProvider>.value(
      value: provider,
      child: Consumer<FormInputProvider>(
        builder: (context, obtainedData, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 127, 116, 62),
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
                leading: BackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TechnicianSignupScreen(
                            controller: RegistrationController("technician"),
                          ),
                        ));
                  },
                ),
                iconTheme: const IconThemeData(
                  size: 40,
                ),
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What is your specialized service area(s)?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[0],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[0] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        0,
                                        "Plumbing",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Plumbing',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[1],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[1] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        1,
                                        "Aircon Servicing",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Aircon Servicing',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[2],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[2] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        2,
                                        "Roof Servicing",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Roof Servicing',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[3],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[3] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        3,
                                        "Electrical & Wiring",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Electrical & Wiring',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[4],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[4] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        4,
                                        "Window & Door",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Window & Door',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: _checkboxValues[5],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkboxValues[5] = value!;
                                      validateCheckbox();
                                    });
                                    widget.controller.checkboxStateChange(
                                        _checkboxValues,
                                        5,
                                        "Painting",
                                        provider);
                                  },
                                ),
                                const Text(
                                  'Painting',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Briefly state your experience with the service area(s):',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _expController,
                                maxLines: 5,
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  provider.saveExp = value;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  'State:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: DropdownButton<String>(
                                      value: _selectedValue,
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
                                        _selectedValue = newValue;
                                        checkCitySelected();
                                        provider.saveCity = _selectedValue!;
                                      },
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                      dropdownColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Address:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
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
                            const SizedBox(height: 25),
                            const Text(
                              'Upload verification document (PDF or Doc), if any:',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 30),
                                ElevatedButton(
                                  onPressed: () => selectFile(provider),
                                  style: filePickBtnStyle,
                                  child: const Text('Select file'),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    provider.fileName ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _isAllValid
                                  ? () => widget.controller.sendPhoneNumber(
                                      context,
                                      provider.phone!,
                                      "technician",
                                      "register")
                                  : null,
                              style: signupBtnStyle.copyWith(
                                backgroundColor: backgroundColor,
                              ),
                              child: const Text('Sign up'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
