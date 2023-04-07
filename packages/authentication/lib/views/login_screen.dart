import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/views/customer_signup_screen.dart';
import 'package:authentication/models/phone_number_formatter.dart';
import 'package:authentication/views/technician_signup_screen.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home/user.dart';
import 'package:better_home/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(
      {Key? key, required this.userType, required this.controller})
      : super(key: key);
  final String userType;
  final LoginController controller;

  @override
  StateMVC<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends StateMVC<LoginScreen> {
  late User _user;
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();

    _phoneController.addListener(() {
      setState(() {
        if (widget.controller.validPhoneFormat(_phoneController.text) == true &&
            _phoneController.text.isNotEmpty) {
          _isValid = true;
        } else {
          _isValid = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> loginBtnClicked() async {
    if (widget.userType == "customer") {
      if (await widget.controller
          .isAccountExists(_phoneController.text, widget.userType)) {
        loginProcess();
      } else {
        showError1();
      }
    } else {
      if (await widget.controller
          .isAccountExists(_phoneController.text, widget.userType)) {
        if (await widget.controller.isApprovedAccount(_phoneController.text)) {
          loginProcess();
        } else {
          showError2();
        }
      } else {
        showError1();
      }
    }
  }

  void loginProcess() {
    widget.controller.sendPhoneNumber(
        context, _phoneController.text, widget.userType, "login");
  }

  void showError1() {
    showDialogBox(context, "Unregistered phone number",
        "Please login with a registered number.");
  }

  void showError2() {
    showDialogBox(context, "Unapproved account",
        "Please wait for admin's approval email.");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
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

    final ButtonStyle signupBtnStyle = ElevatedButton.styleFrom(
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

    return Scaffold(
      backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 45),
              Image.asset(
                'assets/betterhome_logo.png',
                height: 110,
                width: 110,
              ),
              const SizedBox(height: 50),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _phoneController,
                        inputFormatters: [
                          MalaysiaPhoneNumberFormatter(context)
                        ],
                        keyboardType: TextInputType.phone,
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
                      onPressed: _isValid ? loginBtnClicked : null,
                      style: loginBtnStyle.copyWith(
                        backgroundColor: backgroundColor,
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 13),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.userType == "customer") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerSignupScreen(
                                  controller:
                                      RegistrationController("customer"),
                                ),
                              ));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TechnicianSignupScreen(
                                  controller:
                                      RegistrationController("technician"),
                                ),
                              ));
                        }
                      },
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
