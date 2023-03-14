import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/models/phone_number_formatter.dart';
import 'package:authentication/models/user.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:authentication/views/text_field_container.dart';
import 'package:flutter/material.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({Key? key, required this.controller})
      : super(key: key);
  final RegistrationController controller;

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  late User _user;
  bool _isValidName = false;
  bool _isValidEmail = false;
  bool _isValidPhone = false;
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
        } else {
          _isValidName = false;
        }
      });
    });

    _emailController.addListener(() {
      setState(() {});
    });

    _phoneController.addListener(() {
      setState(() {
        if (widget.controller.validPhoneFormat(_phoneController.text) == "" &&
            _phoneController.text.isNotEmpty) {
          _isValidPhone = true;
        } else {
          _isValidPhone = false;
        }
      });
    });
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

    return Scaffold(
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
                        decoration: const InputDecoration(
                          hintText: 'Full name',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          return null;
                        },
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
                        decoration: const InputDecoration(
                          hintText: 'Phone number',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (widget.controller
                            .validPhoneFormat(_phoneController.text) !=
                        "")
                      SizedBox(
                        width: size.width * 0.65,
                        height: 15,
                        child: Text(
                          widget.controller
                              .validPhoneFormat(_phoneController.text),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => widget.controller
                          .sendPhoneNumber(context, _phoneController.text),
                      style: signupBtnStyle.copyWith(
                        backgroundColor: backgroundColor,
                      ),
                      child: const Text('Sign up'),
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                userType: 'customer',
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
    );
  }
/*
  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = _phoneController.text.trim();
    ap.signInWithPhone(context, phoneNumber);
  }*/
}
