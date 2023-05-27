import 'package:better_home/bottom_nav_bar.dart';
import 'package:user_management/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/models/app_notification.dart';
import 'package:user_management/views/notification_container.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen(
      {Key? key, required this.controller, required this.userType})
      : super(key: key);
  final NotificationController controller;
  final String userType;
  final bool isLoading = false;

  @override
  StateMVC<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends StateMVC<NotificationScreen> {
  int _currentIndex = 0;
  List<AppNotification> notifications = [];
  bool isLoading = true;

  @override
  initState() {
    setNotifications();
    super.initState();
  }

  void setNotifications() async {
    notifications =
        await widget.controller.retrieveNotification(widget.userType, context);

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
        title: const Text(
          'Notification',
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
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Color.fromARGB(255, 51, 119, 54),
            ))
          : notifications.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'No notification yet',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        itemCount: notifications.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 16),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final DateTime messageDateTime = widget.controller
                              .formatToLocalDateTime(
                                  notifications[index].dateTime!);
                          final DateTime now = DateTime.now();
                          final currentDate =
                              now.toUtc().add(const Duration(hours: 8));
                          final bool isToday =
                              messageDateTime.year == currentDate.year &&
                                  messageDateTime.month == currentDate.month &&
                                  messageDateTime.day == currentDate.day;

                          String time = '';
                          if (isToday) {
                            time = widget.controller
                                .formatToLocalTime(messageDateTime);
                          } else {
                            time = widget.controller
                                .formatToLocalDate(messageDateTime);
                          }

                          return NotificationContainer(
                            isMessageRead: notifications[index].readStatus!,
                            controller: widget.controller,
                            userType: widget.userType,
                            dateTime: time,
                            notiMessage: notifications[index].notiMessage!,
                            serviceID: notifications[index].serviceID!,
                          );
                        },
                      ),
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
          userType: widget.userType),
    );
  }
}
