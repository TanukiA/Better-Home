import 'dart:io';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/models/user.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class TechnicianSignupScreen2 extends StatefulWidget {
  const TechnicianSignupScreen2({Key? key, required this.controller})
      : super(key: key);
  final RegistrationController controller;

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
  String? _selectedValue;
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<bool> checkboxValues = [false, false, false, false, false, false];

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String fileName = "";
  String _addressPicked = "Pick your address here";

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
    for (bool value in checkboxValues) {
      if (value) {
        isAnyChecked = true;
        break;
      }
    }
    setState(() {
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
    uploadFile();
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
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    // ignore: avoid_print
    print('Download Link: $urlDownload');
  }

  @override
  void dispose() {
    _expController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormInputProvider>(context);
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
                            'Select your state',
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
                            decoration: const InputDecoration(
                              hintText: 'Address',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Upload verification document (PDF or Doc) is any',
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
