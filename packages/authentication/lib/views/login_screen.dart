import 'package:authentication/controllers/login_controller.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.userType}) : super(key: key);
  final String userType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /*
    switch (widget.userType) {
      case 'customer':
        return const Scaffold();
      case 'technician':
        return const Scaffold();
      default:
        return Container();
    }
    */
    return Scaffold(
      backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              'assets/betterhome_logo.png',
              height: 100,
              width: 100,
            ),
            const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white.withOpacity(0.8),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              child: Stack(
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
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
