import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/notification_controller.dart';

class NotificationContainer extends StatefulWidget {
  const NotificationContainer({
    Key? key,
    required this.isMessageRead,
    required this.controller,
    required this.userType,
    required this.serviceID,
    required this.dateTime,
    required this.notiMessage,
  }) : super(key: key);
  final String serviceID;
  final String dateTime;
  final String notiMessage;
  final bool isMessageRead;
  final NotificationController controller;
  final String userType;

  @override
  StateMVC<NotificationContainer> createState() =>
      _NotificationContainerState();
}

class _NotificationContainerState extends StateMVC<NotificationContainer> {
  bool read = false;

  @override
  initState() {
    read = widget.isMessageRead;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller
            .openRelevantScreen(widget.serviceID, widget.userType, context);
        // set notification's read status to true
        widget.controller.setRead(widget.serviceID, widget.userType, context);
        read = true;
        setState(() {});
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: read ? Colors.white : const Color.fromARGB(255, 244, 252, 240),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.notiMessage,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.dateTime,
              style: TextStyle(
                  fontSize: 14,
                  color: read
                      ? const Color.fromARGB(255, 115, 115, 115)
                      : const Color.fromARGB(255, 93, 176, 38)),
            ),
          ],
        ),
      ),
    );
  }
}
