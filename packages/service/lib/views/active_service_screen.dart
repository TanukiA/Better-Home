import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/active_service_detail_screen.dart';

class ActiveServiceScreen extends StatefulWidget {
  const ActiveServiceScreen({Key? key, required this.controller})
      : super(key: key);
  final ServiceController controller;

  @override
  StateMVC<ActiveServiceScreen> createState() => _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends StateMVC<ActiveServiceScreen> {
  List<QueryDocumentSnapshot> servicesDoc = [];
  bool isLoading = true;

  @override
  initState() {
    getServicesData();
    super.initState();
  }

  void getServicesData() async {
    servicesDoc = await widget.controller.retrieveActiveServicesData(context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (servicesDoc.isEmpty && isLoading == false)
          const Center(
              child: Text(
            'No active services available',
            style: TextStyle(
              fontSize: 16,
            ),
          ))
        else
          ListView.builder(
              itemCount: servicesDoc.length,
              itemBuilder: (context, index) {
                final serviceDoc = servicesDoc[index];
                String serviceStatus = (serviceDoc.data()
                    as Map<String, dynamic>)["serviceStatus"];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveServiceDetailScreen(
                          serviceDoc: serviceDoc,
                          controller: widget.controller,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(22, 10, 22, 10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (serviceDoc.data()
                              as Map<String, dynamic>)["serviceName"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          serviceStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFAD07B8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (serviceStatus == "Assigning") ...[
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                  "${widget.controller.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["preferredDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["preferredTime"]}"),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                  "${widget.controller.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["alternativeDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["alternativeTime"]}"),
                            ],
                          ),
                        ],
                        if (serviceStatus == "Confirmed" ||
                            serviceStatus == "In Progress") ...[
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                  "${widget.controller.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["confirmedDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["confirmedTime"]}"),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 51, 119, 54),
            ),
          ),
      ],
    );
  }
}
