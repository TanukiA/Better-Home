import 'package:authentication/models/phone_number_formatter.dart';
import 'package:better_home/text_field_container.dart';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/user_controller.dart';

class EditPhoneScreen extends StatefulWidget {
  const EditPhoneScreen(
      {Key? key, required this.controller, required this.userType})
      : super(key: key);
  final UserController controller;
  final String userType;

  @override
  StateMVC<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends StateMVC<EditPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;

  @override
  initState() {
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

  Future<void> checkUsedOrNot(String phoneInput) async {
    if (await widget.controller.usedPhoneNumber(phoneInput, widget.userType)) {
      if (mounted) {
        showDialogBox(context, "Phone number in use",
            "This phone number is already been used. Please try another.");
      }
    } else {
      if (mounted) {
        widget.controller.sendPhoneNumber(
            context, _phoneController.text, widget.userType, "profile");
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle updateBtnStyle = ElevatedButton.styleFrom(
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 75.0),
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
                inputFormatters: [MalaysiaPhoneNumberFormatter(context)],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'New phone number',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (widget.controller.validPhoneFormat(_phoneController.text) ==
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
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed:
                  _isValid ? () => checkUsedOrNot(_phoneController.text) : null,
              style: updateBtnStyle.copyWith(
                backgroundColor: backgroundColor,
              ),
              child: const Text('Update phone number'),
            ),
          ],
        ),
      ),
    );
  }
}
