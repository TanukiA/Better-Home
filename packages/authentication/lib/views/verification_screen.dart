import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/models/user.dart';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen(
      {Key? key, required this.verificationId, required this.controller})
      : super(key: key);
  final String verificationId;
  final LoginController controller;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late User _user;
  String? otpCode;

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    Size size = MediaQuery.of(context).size;

    final ButtonStyle confirmBtnStyle = ElevatedButton.styleFrom(
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

    final ButtonStyle resendBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(
          color: Colors.black,
          width: 3.0,
        ),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        leading: const BackButton(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(
          size: 40,
        ),
      ),
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                color: Color.fromARGB(255, 51, 119, 54),
              ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Text(
                            'OTP has been sent to your phone SMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 70),
                          Pinput(
                            length: 6,
                            showCursor: true,
                            defaultPinTheme: PinTheme(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF98A17F),
                                ),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onCompleted: (value) {
                              setState(() {
                                otpCode = value;
                              });
                            },
                          ),
                          const SizedBox(height: 80),
                          ElevatedButton(
                            onPressed: () {
                              if (otpCode != null && otpCode!.length == 6) {
                                widget.controller.verifyOTP(
                                    context, otpCode!, widget.verificationId);
                              } else {
                                showSnackBar(
                                    context, "Please enter 6-digit code");
                              }
                            },
                            style: confirmBtnStyle,
                            child: const Text('Confirm'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: resendBtnStyle,
                            child: const Text('Resend'),
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
