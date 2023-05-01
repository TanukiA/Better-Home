import 'package:better_home/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {Key? key, required this.controller, required this.userType})
      : super(key: key);
  final UserController controller;
  final String userType;

  @override
  StateMVC<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends StateMVC<ProfileScreen> {
  int _currentIndex = 0;
  bool isLoading = true;
  late Map<String, dynamic> profileData;
  late String specializationStr;
  double containerHeight = 0;

  @override
  initState() {
    setProfileData();
    if (widget.userType == "customer") {
      containerHeight = 280;
    } else {
      containerHeight = 470;
    }
    super.initState();
  }

  Future<void> setProfileData() async {
    final profileDoc =
        await widget.controller.retrieveProfileData(widget.userType, context);
    profileData = profileDoc.data() as Map<String, dynamic>;
    List<dynamic> specialization = profileData["specialization"];
    specializationStr = specialization.join(", ");
    if (mounted) {
      widget.controller.saveProfileToProvider(
          context, profileData, widget.userType, specializationStr);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle reviewBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.7, 50),
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
          "Profile",
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
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Color.fromARGB(255, 51, 119, 54),
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.userType == "technician") ...[
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        // review
                      },
                      style: reviewBtnStyle,
                      child: const Text('Your customer review'),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Container(
                    width: double.infinity,
                    height: containerHeight,
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  widget.controller.handleEditIcon(
                                      widget.userType, profileData, context);
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 35.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Full name:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${profileData["name"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
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
                        Text(
                          "${profileData["email"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
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
                          "${profileData["phoneNumber"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        if (widget.userType == "technician") ...[
                          const Text(
                            'Specialization:',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            specializationStr,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'State:',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "${profileData["city"]}",
                            style: const TextStyle(
                              fontSize: 16.0,
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
                          Text(
                            "${profileData["address"]}",
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: size.width * 0.8,
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 218, 218, 218),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Change phone number",
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(width: 30.0),
                        InkWell(
                          onTap: () {
                            // add function to run when icon is tapped
                          },
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
      bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          userType: widget.userType),
    );
  }
}