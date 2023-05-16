import 'package:better_home/text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/views/search_place_screen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:user_management/controllers/user_controller.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:user_management/views/profile_screen.dart';

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
  String? _selectedValue;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  initState() {
    final provider = Provider.of<ProfileEditProvider>(context, listen: false);
    super.initState();
    _nameController = TextEditingController(text: provider.name);
    _emailController = TextEditingController(text: provider.email);
    _addressController = TextEditingController(text: provider.address);
    _selectedValue = provider.city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final provider = Provider.of<ProfileEditProvider>(context);

    final ButtonStyle cancelBtnStyle = ElevatedButton.styleFrom(
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
      backgroundColor: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      widget.controller
                          .handleSaveIcon(context, widget.userType, provider);
                    },
                    child: const Icon(
                      Icons.save,
                      size: 37.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Full name:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5.0),
              TextFieldContainer(
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    provider.saveName = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Email:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5.0),
              TextFieldContainer(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    provider.saveEmail = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Phone number:',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                "${provider.phone}",
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 28.0),
              if (widget.userType == "technician") ...[
                const Text(
                  'Specialization:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  "${provider.specs}",
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 28.0),
                const Text(
                  'State:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedValue,
                      items: [
                        ...<String>[
                          'Kuala Lumpur / Selangor',
                          'Putrajaya',
                          'Johor',
                          'Kedah',
                          'Kelantan',
                          'Melaka',
                          'Negeri Sembilan',
                          'Pahang',
                          'Perak',
                          'Pulau Pinang'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) {
                        _selectedValue = newValue;
                        provider.saveCity = newValue!;
                      },
                      hint: _selectedValue == null
                          ? const Text("Select your state")
                          : null,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      dropdownColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Address:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPlaceScreen(
                                controller: LocationController(),
                                purpose: "profile",
                                userType: widget.userType,
                              )),
                    );
                  },
                  child: TextFieldContainer(
                    child: TextFormField(
                      enabled: false,
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Pick your address here',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 48, 48, 48),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  provider.clearFormInputs();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        controller: UserController(widget.userType),
                        userType: widget.userType,
                      ),
                    ),
                  );
                },
                style: cancelBtnStyle,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
