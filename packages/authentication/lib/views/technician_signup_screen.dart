import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/models/phone_number_formatter.dart';
import 'package:better_home/user.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:authentication/views/technician_signup_screen2.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:better_home/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class TechnicianSignupScreen extends StatefulWidget {
  const TechnicianSignupScreen({Key? key, required this.controller})
      : super(key: key);
  final RegistrationController controller;

  @override
  State<TechnicianSignupScreen> createState() => _TechnicianSignupScreenState();
}

class _TechnicianSignupScreenState extends State<TechnicianSignupScreen> {
  late User _user;
  bool _isValidName = false;
  bool _isValidEmail = false;
  bool _isValidPhone = false;
  bool _isAllValid = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();

    _nameController.addListener(() {
      setState(() {
        if (_nameController.text.isNotEmpty) {
          _isValidName = true;
          if (widget.controller
              .checkValidForm(_isValidName, _isValidEmail, _isValidPhone)) {
            _isAllValid = true;
          }
        } else {
          _isValidName = false;
          _isAllValid = false;
        }
      });
    });

    _emailController.addListener(() {
      setState(() {
        if (widget.controller.validEmailFormat(_emailController.text) == true &&
            _emailController.text.isNotEmpty) {
          _isValidEmail = true;
          if (widget.controller
              .checkValidForm(_isValidName, _isValidEmail, _isValidPhone)) {
            _isAllValid = true;
          }
        } else {
          _isValidEmail = false;
          _isAllValid = false;
        }
      });
    });

    _phoneController.addListener(() {
      setState(() {
        if (widget.controller.validPhoneFormat(_phoneController.text) == true &&
            _phoneController.text.isNotEmpty) {
          _isValidPhone = true;
          if (widget.controller
              .checkValidForm(_isValidName, _isValidEmail, _isValidPhone)) {
            _isAllValid = true;
          }
        } else {
          _isValidPhone = false;
          _isAllValid = false;
        }
      });
    });
  }

  Future<void> continueBtnClicked() async {
    if (await widget.controller
        .isAccountExists(_phoneController.text, "technician")) {
      showError();
    } else {
      pushToNextScreen();
    }
  }

  void pushToNextScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TechnicianSignupScreen2(
            controller: RegistrationController(),
          ),
        ));
  }

  void showError() {
    showDialogBox(context, "Phone number already exists",
        "This phone number is already registered. Please login instead.");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FormInputProvider provider =
        Provider.of<FormInputProvider>(context, listen: false);
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

    final ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

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
              backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 70),
                      const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  provider.saveName = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Full name',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  provider.saveEmail = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (widget.controller
                                    .validEmailFormat(_emailController.text) ==
                                false)
                              SizedBox(
                                width: size.width * 0.65,
                                height: 15,
                                child: const Text(
                                  'Invalid email address',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: _phoneController,
                                inputFormatters: [
                                  MalaysiaPhoneNumberFormatter(context)
                                ],
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  provider.savePhone = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Phone number',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (widget.controller
                                    .validPhoneFormat(_phoneController.text) ==
                                false)
                              SizedBox(
                                width: size.width * 0.65,
                                height: 15,
                                child: const Text(
                                  'Invalid phone number',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  _isAllValid ? continueBtnClicked : null,
                              style: signupBtnStyle.copyWith(
                                backgroundColor: backgroundColor,
                              ),
                              child: const Text('Continue'),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Already have account?",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 13),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(
                                        userType: 'technician',
                                        controller: LoginController(),
                                      ),
                                    ));
                              },
                              style: loginBtnStyle,
                              child: const Text('Login'),
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
