import 'package:better_home/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:service/views/update_status_dialog.dart';
import 'package:user_management/controllers/messaging_controller.dart';

class WorkSchedulesDetailScreen extends StatefulWidget {
  const WorkSchedulesDetailScreen(
      {Key? key,
      required this.serviceDoc,
      required this.serviceCon,
      required this.msgCon})
      : super(key: key);
  final QueryDocumentSnapshot serviceDoc;
  final ServiceController serviceCon;
  final MessagingController msgCon;

  @override
  StateMVC<WorkSchedulesDetailScreen> createState() =>
      _WorkSchedulesDetailScreenState();
}

class _WorkSchedulesDetailScreenState
    extends StateMVC<WorkSchedulesDetailScreen> {
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
    Size size = MediaQuery.of(context).size;

    final ButtonStyle updateStatusBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.65, 55),
      elevation: 3,
    );

    final ButtonStyle messageBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.3, 45),
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
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateStatusDialog(
                            controller: widget.serviceCon,
                            serviceDoc: widget.serviceDoc,
                          );
                        },
                      );
                    },
                    style: updateStatusBtnStyle,
                    child: const Text('Update Service Status'),
                  ),
                  const SizedBox(height: 18),
                  if ((widget.serviceDoc.data()
                          as Map<String, dynamic>)["serviceStatus"] !=
                      "Assigning") ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 232, 232, 232),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Customer: ',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 18.0),
                          ElevatedButton(
                            onPressed: () {
                              widget.msgCon.messageBtnTapped(
                                  context,
                                  (widget.serviceDoc.data()
                                      as Map<String, dynamic>)["customerID"],
                                  "technician",
                                  customerName);
                            },
                            style: messageBtnStyle,
                            child: const Text('Message'),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          alignment: Alignment.center,
                          child: Text(
                            "${(widget.serviceDoc.data() as Map<String, dynamic>)["serviceStatus"]}",
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
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
                          'Confirmed Appointment:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "${widget.serviceCon.formatToLocalDate((widget.serviceDoc.data() as Map<String, dynamic>)["confirmedDate"])}, ${(widget.serviceDoc.data() as Map<String, dynamic>)["confirmedTime"]}",
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
                        const SizedBox(height: 30.0),
                        Text(
                          '# Requested on ${widget.serviceCon.formatToLocalDateTime((widget.serviceDoc.data() as Map<String, dynamic>)["dateTimeSubmitted"])}',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 15.0),
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
                  const SizedBox(height: 15),
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
