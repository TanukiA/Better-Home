import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:service/controllers/technician_controller.dart';

class AssignedServiceScreen extends StatefulWidget {
  const AssignedServiceScreen(
      {Key? key,
      required this.serviceDoc,
      required this.techCon,
      required this.serviceCon})
      : super(key: key);
  final QueryDocumentSnapshot serviceDoc;
  final TechnicianController techCon;
  final ServiceController serviceCon;

  @override
  StateMVC<AssignedServiceScreen> createState() =>
      _AssignedServiceScreenState();
}

class _AssignedServiceScreenState extends StateMVC<AssignedServiceScreen> {
  int _currentIndex = 0;
  String customerName = "";
  bool isLoading = true;

  @override
  initState() {
    setCustomerName();
    super.initState();
  }

  Future<void> setCustomerName() async {
    customerName =
        await widget.serviceCon.retrieveCustomerName(widget.serviceDoc);
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${(widget.serviceDoc.data() as Map<String, dynamic>)["serviceName"]}",
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
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Assigned on ${widget.serviceCon.formatToLocalDateTime((widget.serviceDoc.data() as Map<String, dynamic>)["dateTimeSubmitted"])}",
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        const Text(
                          'Service Type:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["serviceName"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Variation:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["serviceVariation"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Customer:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Appointment:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${widget.serviceCon.formatToLocalDate((widget.serviceDoc.data() as Map<String, dynamic>)["assignedDate"])}, ${(widget.serviceDoc.data() as Map<String, dynamic>)["assignedTime"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Property Type:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["propertyType"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'State:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["city"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Address:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["address"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${(widget.serviceDoc.data() as Map<String, dynamic>)["description"]}",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 25.0),
                      ],
                    ),
                  ),
                  FutureBuilder<List<Widget>>(
                      future: widget.serviceCon
                          .retrieveServiceImages(widget.serviceDoc),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            width: 300.0,
                            height: 250.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data!,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 62,
                        ),
                        onPressed: () {
                          widget.techCon
                              .acceptIconPressed(widget.serviceDoc, context);
                        },
                      ),
                      const SizedBox(width: 80),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: Colors.red,
                          size: 62,
                        ),
                        onPressed: () {
                          widget.techCon
                              .rejectIconPressed(widget.serviceDoc, context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TechnicianHomeScreen(
                                loginCon: LoginController("technician"),
                                techCon: TechnicianController(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 38),
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
          userType: "technician"),
    );
  }
}
