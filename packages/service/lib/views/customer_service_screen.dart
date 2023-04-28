import 'package:flutter/material.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/active_service_screen.dart';
import 'package:service/views/past_service_screen.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({Key? key, required this.initialIndex}) : super(key: key);
  final int initialIndex;

  @override
  StateMVC<CustomerServiceScreen> createState() =>
      _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends StateMVC<CustomerServiceScreen> {
  int _currentIndex = 0;
  int _initialIndex = 0;

  @override
  initState() {
    _initialIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _initialIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8E5D4),
        appBar: AppBar(
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Active Services'),
              Tab(text: 'Past Services'),
            ],
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50), // Creates border
                color: const Color.fromARGB(255, 46, 83, 49)),
          ),
          centerTitle: true,
          title: const Text(
            "Services",
            style: TextStyle(
              fontSize: 25,
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
        body: TabBarView(
          children: [
            ActiveServiceScreen(controller: ServiceController()),
            PastServiceScreen(controller: ServiceController()),
          ],
        ),
        bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            userType: "customer"),
      ),
    );
  }
}
