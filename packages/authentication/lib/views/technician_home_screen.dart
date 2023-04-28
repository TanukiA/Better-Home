import 'package:authentication/controllers/login_controller.dart';
import 'package:better_home/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home/bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:service/views/assigned_service_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen(
      {Key? key, required this.loginCon, required this.techCon})
      : super(key: key);
  final LoginController loginCon;
  final TechnicianController techCon;

  @override
  StateMVC<TechnicianHomeScreen> createState() => _TechnicainHomeScreenState();
}

class _TechnicainHomeScreenState extends StateMVC<TechnicianHomeScreen> {
  int _currentIndex = 0;
  List<QueryDocumentSnapshot> servicesDoc = [];
  bool isLoading = true;

  @override
  void initState() {
    getAssignedServicesData();
    super.initState();
  }

  void getAssignedServicesData() async {
    servicesDoc = await widget.techCon.retrieveAssignedServices(context);

    setState(() {
      isLoading = false;
    });
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
                  height: size.height * 0.8,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/accept_tasks_img.svg',
                        width: size.width * 0.4,
                        height: size.height * 0.15,
                      ),
                      const SizedBox(height: 20),
                      if (isLoading == false)
                        Center(
                          child: Text(
                            'You have ${servicesDoc.length} pending service request(s)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 51, 119, 54),
                          ),
                        )
                      else if (isLoading == false && servicesDoc.isEmpty)
                        const SizedBox.shrink()
                      else
                        SingleChildScrollView(
                          child: SizedBox(
                            height: size.height * 0.5,
                            child: ListView.builder(
                                itemCount: servicesDoc.length,
                                itemBuilder: (context, index) {
                                  final serviceDoc = servicesDoc[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssignedServiceScreen(
                                            serviceDoc: serviceDoc,
                                            techCon: widget.techCon,
                                            serviceCon: ServiceController(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.fromLTRB(
                                          22, 10, 22, 10),
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 3,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (serviceDoc.data() as Map<String,
                                                dynamic>)["serviceName"],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  color: Colors.black),
                                              const SizedBox(width: 10),
                                              Text(
                                                  "${widget.techCon.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["assignedDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["assignedTime"]}"),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.black),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  "${(serviceDoc.data() as Map<String, dynamic>)["address"]}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
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
          userType: "technician"),
    );
  }
}
