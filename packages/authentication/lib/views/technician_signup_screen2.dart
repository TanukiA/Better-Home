import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/models/technician.dart';
import 'package:authentication/models/user.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';

class TechnicianSignupScreen2 extends StatefulWidget {
  const TechnicianSignupScreen2(
      {Key? key, required this.controller, required this.provider})
      : super(key: key);
  final RegistrationController controller;
  final FormInputProvider provider;

  @override
  State<TechnicianSignupScreen2> createState() =>
      _TechnicianSignupScreen2State();
}

class _TechnicianSignupScreen2State extends State<TechnicianSignupScreen2> {
  late User _user;
  bool _isValidSpec = false;
  bool _isValidExp = false;
  bool _isValidCity = false;
  bool _isValidAddress = false;
  bool _isAllValid = false;
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<bool> checkboxValues = [false, false, false, false, false, false];

  String? _selectedValue = 'Select your state';
  String fileName = "";
  PlatformFile? pickedFile;
  String _addressPicked = "Pick your address here";
  List<String> specs = [];

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();

    _expController.addListener(() {
      setState(() {
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
      });
    });

    _addressController.addListener(() {
      setState(() {
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
      });
    });
  }

  void validateCheckbox() {
    bool isAnyChecked = false;

    setState(() {
      for (bool value in checkboxValues) {
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

  Future<void> signupBtnClicked() async {
    widget.controller.uploadFile(pickedFile);
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      fileName = pickedFile!.name;
    });
    widget.provider.formInput = Technician(
      name: widget.provider.formInput.name,
      email: widget.provider.formInput.email,
      phone: widget.provider.formInput.phone,
      specs: widget.provider.formInput.specs,
      exp: widget.provider.formInput.exp,
      city: widget.provider.formInput.city,
      address: widget.provider.formInput.address,
      latLong: widget.provider.formInput.latLong,
      pickedFile: pickedFile,
    );
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

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when user taps anywhere outside the TextFormField
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
          leading: const BackButton(
            color: Colors.black,
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
                      const Text(
                        'What is your specialized service area(s)?',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.black,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[0],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[0] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  0,
                                  "Plumbing",
                                  specs,
                                  widget.provider);
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
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[1],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[1] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  1,
                                  "Aircon Servicing",
                                  specs,
                                  widget.provider);
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
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[2],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[2] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  2,
                                  "Roof Servicing",
                                  specs,
                                  widget.provider);
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
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[3],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[3] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  3,
                                  "Electrical & Wiring",
                                  specs,
                                  widget.provider);
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
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[4],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[4] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  4,
                                  "Window & Door",
                                  specs,
                                  widget.provider);
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
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: checkboxValues[5],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxValues[5] = value!;
                                validateCheckbox();
                              });
                              specs = widget.controller.checkboxStateChange(
                                  checkboxValues,
                                  5,
                                  "Painting",
                                  specs,
                                  widget.provider);
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
                      const Text(
                        'Briefly state your experience with the service area(s):',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFieldContainer(
                        child: TextFormField(
                          controller: _expController,
                          maxLines: 5,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            widget.provider.formInput = Technician(
                              name: widget.provider.formInput.name,
                              email: widget.provider.formInput.email,
                              phone: widget.provider.formInput.phone,
                              specs: widget.provider.formInput.specs,
                              exp: value,
                              city: widget.provider.formInput.city,
                              address: widget.provider.formInput.address,
                              latLong: widget.provider.formInput.latLong,
                              pickedFile: widget.provider.formInput.pickedFile,
                            );
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedValue,
                          isExpanded: true,
                          items: <String>[
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
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedValue = newValue;
                              _isValidCity = _selectedValue != null &&
                                  _selectedValue != 'Select your state';
                              if (_isValidCity) {
                                if (widget.controller.checkValidTechnicianForm(
                                    _isValidSpec,
                                    _isValidExp,
                                    _isValidCity,
                                    _isValidAddress)) {
                                  _isAllValid = true;
                                }
                              } else {
                                _isAllValid = false;
                              }
                            });
                            widget.provider.formInput = Technician(
                              name: widget.provider.formInput.name,
                              email: widget.provider.formInput.email,
                              phone: widget.provider.formInput.phone,
                              specs: widget.provider.formInput.specs,
                              exp: widget.provider.formInput.exp,
                              city: newValue,
                              address: widget.provider.formInput.address,
                              latLong: widget.provider.formInput.latLong,
                              pickedFile: widget.provider.formInput.pickedFile,
                            );
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final passedAddress = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPlaceScreen(
                                      controller: LocationController(),
                                    )),
                          );
                          setState(() {
                            _addressPicked = passedAddress;
                          });
                        },
                        child: TextFieldContainer(
                          child: TextFormField(
                            enabled: false,
                            initialValue: _addressPicked,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              widget.provider.formInput = Technician(
                                name: widget.provider.formInput.name,
                                email: widget.provider.formInput.email,
                                phone: widget.provider.formInput.phone,
                                specs: widget.provider.formInput.specs,
                                exp: widget.provider.formInput.exp,
                                city: widget.provider.formInput.city,
                                address: value,
                                latLong: widget.provider.formInput.latLong,
                                pickedFile:
                                    widget.provider.formInput.pickedFile,
                              );
                            },
                            decoration: const InputDecoration(
                              hintText: 'Address',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Upload verification document (PDF or Doc) if any',
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
                            onPressed: selectFile,
                            style: filePickBtnStyle,
                            child: const Text('Select file'),
                          ),
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isAllValid ? signupBtnClicked : null,
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
  }
}
