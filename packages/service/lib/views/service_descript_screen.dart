import 'package:flutter/material.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/customer_controller.dart';

class ServiceDescriptionScreen extends StatefulWidget {
  const ServiceDescriptionScreen(
      {Key? key,
      required this.serviceCategory,
      required this.serviceType,
      required this.controller})
      : super(key: key);
  final String serviceCategory;
  final String serviceType;
  final CustomerController controller;

  @override
  StateMVC<ServiceDescriptionScreen> createState() =>
      _ServiceDescriptionScreenState();
}

class _ServiceDescriptionScreenState
    extends StateMVC<ServiceDescriptionScreen> {
  int _currentIndex = 0;
  List<String> explanations = [];
  String priceRange = "";
  String imgPath = "";
  bool isLoading = true;

  @override
  initState() {
    getTexts();
    super.initState();
  }

  Future<void> getTexts() async {
    final descripText = await widget.controller
        .retrieveServiceDescription(widget.serviceCategory, widget.serviceType);

    setState(() {
      explanations = widget.controller.retrieveExplanations(descripText);
      priceRange = widget.controller.retrievePriceRange(descripText);
      imgPath = widget.controller.retrieveImgPath(descripText);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.serviceType,
          style: const TextStyle(
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
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      imgPath,
                      width: size.width * 0.7,
                      height: size.height * 0.2,
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Scope of Service:",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              itemCount: explanations.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    "- ${explanations[index]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Text(
                            "Price: $priceRange",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              widget.controller.setServiceRequestForm(
                                  widget.serviceCategory,
                                  widget.serviceType,
                                  context);
                            },
                            style: btnStyle,
                            child: const Text('Request Service'),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Notes:\n- You will get notified when a suitable technician is assigned.\n- You can cancel your service as long as it is 12 hours before appointment time.",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          userType: "customer"),
    );
  }
}
