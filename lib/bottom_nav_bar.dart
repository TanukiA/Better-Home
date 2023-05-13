import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:service/views/customer_service_screen.dart';
import 'package:service/views/technician_service_screen.dart';
import 'package:user_management/controllers/user_controller.dart';
import 'package:user_management/views/profile_screen.dart';
import 'package:user_management/views/messaging_list_screen.dart';
import 'package:user_management/controllers/messaging_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
  }) : super(key: key);

  final int currentIndex;
  final String userType;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: GestureDetector(
            child: const Icon(Icons.home, color: Colors.black, size: 33),
            onTap: () {
              if (userType == "customer") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerHomeScreen(
                      loginCon: LoginController(userType),
                      cusCon: CustomerController(),
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TechnicianHomeScreen(
                      loginCon: LoginController(userType),
                      techCon: TechnicianController(),
                    ),
                  ),
                );
              }
            },
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            child: const Icon(Icons.build, color: Colors.black, size: 30),
            onTap: () {
              if (userType == "customer") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CustomerServiceScreen(initialIndex: 0),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TechnicianServiceScreen(),
                  ),
                );
              }
            },
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            child: const Icon(Icons.message, color: Colors.black, size: 30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagingListScreen(
                    controller: MessagingController(),
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.black, size: 30),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            child: const Icon(Icons.account_circle_sharp,
                color: Colors.black, size: 33),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    controller: UserController(userType),
                    userType: userType,
                  ),
                ),
              );
            },
          ),
          label: '',
        ),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
