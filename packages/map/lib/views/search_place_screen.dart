import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:authentication/models/user.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen(
      {Key? key, required this.userType, required this.controller})
      : super(key: key);
  final String userType;
  final LocationController controller;

  @override
  StateMVC<SearchPlaceScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends StateMVC<SearchPlaceScreen> {
  late User _user;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();

    _addressController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> loginBtnClicked() async {}

  @override
  Widget build(BuildContext context) {
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

    return const Scaffold(
      backgroundColor: Color.fromRGBO(182, 162, 110, 1),
      body: Center(),
    );
  }
}
