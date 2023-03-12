import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_signup_screen.dart';
import 'package:authentication/models/phone_number_formatter.dart';
import 'package:authentication/views/technician_signup_screen.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/user.dart';

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
  // late String phoneValidation;
/*
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      phoneValidation =
          widget.controller.validPhoneNumber(_phoneController.text);
    });
  }*/

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
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

    return Scaffold(
      backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      inputFormatters: [MalaysiaPhoneNumberFormatter(context)],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        errorText: widget.controller
                            .validPhoneNumber(_phoneController.text),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: loginBtnStyle,
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
                              builder: (context) =>
                                  const CustomerSignupScreen(),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TechnicianSignupScreen(),
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
    );
  }
}
