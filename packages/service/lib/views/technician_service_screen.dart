import 'package:flutter/material.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/technician_past_service_screen.dart';
import 'package:service/views/work_schedules_screen.dart';

class TechnicianServiceScreen extends StatefulWidget {
  const TechnicianServiceScreen({Key? key}) : super(key: key);

  @override
  StateMVC<TechnicianServiceScreen> createState() =>
      _TechnicianServiceScreenState();
}

class _TechnicianServiceScreenState extends StateMVC<TechnicianServiceScreen> {
  int _currentIndex = 0;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8E5D4),
        appBar: AppBar(
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Work Schedules'),
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
            WorkScheduleScreen(controller: ServiceController()),
            TechnicianPastServiceScreen(controller: ServiceController()),
          ],
        ),
        bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            userType: "technician"),
      ),
    );
  }
}
