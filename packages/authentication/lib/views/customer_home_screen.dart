import 'package:authentication/controllers/login_controller.dart';
import 'package:better_home/user.dart';
import 'package:better_home/customer.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home/bottom_nav_bar.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen(
      {Key? key, required this.loginCon, required this.cusCon})
      : super(key: key);
  final LoginController loginCon;
  final CustomerController cusCon;

  @override
  StateMVC<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends StateMVC<CustomerHomeScreen> {
  late User _user;
  late Customer _cus;
  int _currentIndex = 0;

  @override
  void initState() {
    _user = widget.loginCon.user;
    _cus = widget.cusCon.cus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 15,
          fontFamily: 'Roboto',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        fixedSize: const Size(130, 80),
        elevation: 5);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Transform.scale(
            scale: 1.5,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: const Text('Logout'),
                    onTap: () {
                      widget.loginCon.logout(context);
                    },
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(152, 161, 127, 1),
                Color(0xFFE8E5D4),
              ],
              stops: [0.15, 0.5],
            ),
          ),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'BetterHome.',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'solutions for your home',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/renovation_img.jpg',
                        width: size.width * 0.3,
                        height: size.height * 0.2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Plumbing', context);
                            },
                            style: btnStyle,
                            child: const Text('Plumbing'),
                          ),
                          const SizedBox(width: 22),
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Aircon Servicing', context);
                            },
                            style: btnStyle,
                            child: const Text(
                              'Aircon Servicing',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Roof Servicing', context);
                            },
                            style: btnStyle,
                            child: const Text(
                              'Roof Servicing',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 22),
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Electrical & Wiring', context);
                            },
                            style: btnStyle,
                            child: const Text(
                              'Electrical & Wiring',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Window & Door', context);
                            },
                            style: btnStyle,
                            child: const Text(
                              'Window & Door',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 22),
                          ElevatedButton(
                            onPressed: () {
                              widget.cusCon.setServiceCategoryScreen(
                                  'Painting', context);
                            },
                            style: btnStyle,
                            child: const Text('Painting'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
