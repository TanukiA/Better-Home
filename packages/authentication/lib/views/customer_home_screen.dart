import 'package:authentication/controllers/login_controller.dart';
import 'package:better_home/user.dart';
import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key, required this.controller})
      : super(key: key);
  final LoginController controller;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late User _user;
  int _currentIndex = 0;

  @override
  void initState() {
    _user = widget.controller.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                      widget.controller.logout(context);
                    },
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(152, 161, 127, 1),
              Color(0xFFE8E5D4),
            ],
            stops: [0.2, 0.6],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black, size: 33),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build, color: Colors.black, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.black, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.black, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.account_circle_sharp, color: Colors.black, size: 33),
            label: '',
          ),
        ],
      ),
    );
  }
}
