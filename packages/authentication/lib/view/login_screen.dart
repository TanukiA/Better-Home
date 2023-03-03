import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.userType}) : super(key: key);
  final String userType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    switch (widget.userType) {
      case 'customer':
        return const Scaffold();
      case 'technician':
        return const Scaffold();
      default:
        return Container();
    }
  }
}
