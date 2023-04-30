import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/technician_past_service_detail_screen.dart';

class TechnicianPastServiceScreen extends StatefulWidget {
  const TechnicianPastServiceScreen({Key? key, required this.controller})
      : super(key: key);
  final ServiceController controller;

  @override
  StateMVC<TechnicianPastServiceScreen> createState() =>
      _TechnicianPastServiceScreenState();
}

class _TechnicianPastServiceScreenState
    extends StateMVC<TechnicianPastServiceScreen> {
  List<QueryDocumentSnapshot> servicesDoc = [];
  bool isLoading = true;
  String selectedServiceStatus = "All service status";
  final List<String> serviceStatusOptions = [
    "All service status",
    "Completed",
    "Rated",
    "Cancelled",
    "Refunded",
  ];

  @override
  initState() {
    getServicesData();
    super.initState();
  }

  void getServicesData() async {
    servicesDoc = await widget.controller
        .retrievePastServicesData(context, 'technicianID');
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return servicesDoc.isEmpty && isLoading == false
        ? const Center(
            child: Text(
            'No past services available',
            style: TextStyle(
              fontSize: 16,
            ),
          ))
        : Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                padding: const EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedServiceStatus,
                  items: serviceStatusOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedServiceStatus = newValue!;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: servicesDoc.length,
                    itemBuilder: (context, index) {
                      final serviceDoc = servicesDoc[index];
                      String serviceStatus = (serviceDoc.data()
                          as Map<String, dynamic>)["serviceStatus"];

                      if (selectedServiceStatus != "All service status" &&
                          selectedServiceStatus != serviceStatus) {
                        return const SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TechnicianPastServiceDetailScreen(
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
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.black),
                                  const SizedBox(width: 10),
                                  Text(((serviceDoc.data() as Map<String,
                                                  dynamic>)["confirmedTime"] !=
                                              null &&
                                          (serviceDoc.data() as Map<String,
                                                  dynamic>)["confirmedTime"] !=
                                              "")
                                      ? "${widget.controller.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["confirmedDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["confirmedTime"]}"
                                      : "${widget.controller.formatToLocalDate((serviceDoc.data() as Map<String, dynamic>)["assignedDate"])}, ${(serviceDoc.data() as Map<String, dynamic>)["assignedTime"]}"),
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
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
