import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/customer_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final int currentIndex;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerHomeScreen(
                    loginCon: LoginController(),
                    cusCon: CustomerController(),
                  ),
                ),
              );
            },
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.build, color: Colors.black, size: 30),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message, color: Colors.black, size: 30),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.black, size: 30),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_sharp, color: Colors.black, size: 33),
          label: '',
        ),
      ],
    );
  }
}
