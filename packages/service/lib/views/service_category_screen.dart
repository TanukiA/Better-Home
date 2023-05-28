import 'package:flutter/material.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/customer_controller.dart';

class ServiceCategoryScreen extends StatefulWidget {
  const ServiceCategoryScreen(
      {Key? key,
      required this.serviceCategory,
      required this.services,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final List<String> services;
  final CustomerController controller;

  @override
  StateMVC<ServiceCategoryScreen> createState() =>
      _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends StateMVC<ServiceCategoryScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 18,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      fixedSize: const Size(300, 70),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.serviceCategory,
          style: const TextStyle(
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
      body: Center(
        child: ListView.builder(
          itemCount: widget.services.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    widget.controller.setServiceDescriptionScreen(
                        widget.serviceCategory,
                        widget.services[index],
                        context);
                  },
                  style: btnStyle,
                  child: Text(
                    widget.services[index],
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          userType: "customer"),
    );
  }
}
