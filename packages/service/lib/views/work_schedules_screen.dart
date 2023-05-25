import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/work_schedules_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_management/controllers/messaging_controller.dart';

class WorkScheduleScreen extends StatefulWidget {
  const WorkScheduleScreen({Key? key, required this.controller})
      : super(key: key);
  final ServiceController controller;

  @override
  StateMVC<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends StateMVC<WorkScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<QueryDocumentSnapshot> servicesDoc = [];
  bool isLoading = true;

  @override
  initState() {
    getServicesData();
    super.initState();
  }

  void getServicesData() async {
    servicesDoc = await widget.controller.retrieveWorkScheduleData(context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 51, 119, 54),
                  ),
                )
              : ListView.builder(
                  itemCount: servicesDoc.length,
                  itemBuilder: (context, index) {
                    final serviceDoc = servicesDoc[index];
                    var confirmedDate = widget.controller.dateInDateTime(
                        (serviceDoc.data()
                            as Map<String, dynamic>)["confirmedDate"]);
                    if (isSameDay(confirmedDate, _selectedDay)) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkSchedulesDetailScreen(
                                serviceDoc: serviceDoc,
                                serviceCon: widget.controller,
                                msgCon: MessagingController(),
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
                                (serviceDoc.data()
                                    as Map<String, dynamic>)["serviceStatus"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFAD07B8),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.black),
                                  const SizedBox(width: 10),
                                  Text(
                                      "${(serviceDoc.data() as Map<String, dynamic>)["confirmedTime"]}"),
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
                    } else {
                      return const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text(
                              'No appointment(s) on this day',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}
