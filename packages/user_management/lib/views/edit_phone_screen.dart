import 'package:better_home/bottom_nav_bar.dart';
import 'package:better_home/text_field_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:user_management/controllers/user_controller.dart';
import 'package:user_management/models/profile_edit_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen(
      {Key? key, required this.controller, required this.userType})
      : super(key: key);
  final UserController controller;
  final String userType;

  @override
  StateMVC<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends StateMVC<EditProfileScreen> {
  double containerHeight = 0;
  final TextEditingController _phoneController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final provider = Provider.of<ProfileEditProvider>(context);

    final ButtonStyle updateBtnStyle = ElevatedButton.styleFrom(
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

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 22,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            const Text(
              'Enter new phone number:',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 5.0),
            TextFieldContainer(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  provider.savePhone = value;
                },
                decoration: const InputDecoration(
                  hintText: 'New phone number',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () async {
                // OTP
              },
              style: updateBtnStyle,
              child: const Text('Update phone number'),
            ),
          ],
        ),
      ),
    );
  }
}
