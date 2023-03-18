import 'package:flutter/material.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({Key? key}) : super(key: key);

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return const Scaffold(
      body: Center(
        child: Text("technician home screen"),
      ),
    );
  }
}
