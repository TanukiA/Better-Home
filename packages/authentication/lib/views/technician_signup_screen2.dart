import 'dart:io';
import 'package:authentication/views/text_field_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TechnicianSignupScreen2 extends StatefulWidget {
  const TechnicianSignupScreen2({Key? key}) : super(key: key);

  @override
  State<TechnicianSignupScreen2> createState() =>
      _TechnicianSignupScreen2State();
}

class _TechnicianSignupScreen2State extends State<TechnicianSignupScreen2> {
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<bool> checkboxValues = [false, false, false, false, false, false];

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String fileName = "";

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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle signupBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.black,
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

    return Scaffold(
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
                            });
                          },
                        ),
                        const Text(
                          'Rood Servicing',
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
                    const SizedBox(height: 10),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _expController,
                        decoration: const InputDecoration(
                          hintText: 'Experience',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please state your experience briefly';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Address',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Upload verification document (PDF or Doc)',
                      style: TextStyle(
                        fontSize: 14,
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
                      onPressed: uploadFile,
                      style: signupBtnStyle,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
