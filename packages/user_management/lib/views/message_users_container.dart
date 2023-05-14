import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/messaging_controller.dart';
import 'package:user_management/models/message.dart';

class MessageUsersContainer extends StatefulWidget {
  const MessageUsersContainer({
    Key? key,
    required this.name,
    required this.messageText,
    required this.time,
    required this.isMessageRead,
    required this.messages,
    required this.controller,
    required this.userType,
  }) : super(key: key);
  final String name;
  final String messageText;
  final String time;
  final bool isMessageRead;
  final List<Message> messages;
  final MessagingController controller;
  final String userType;

  @override
  StateMVC<MessageUsersContainer> createState() =>
      _MessageUsersContainerState();
}

class _MessageUsersContainerState extends StateMVC<MessageUsersContainer> {
  String messagePersonID = "";
  String messagePersonName = "";
  String currentID = "";

  @override
  initState() {
    print("isMessageRead: ${widget.isMessageRead}");
    setTechnicianAndCustomerInfo();
    super.initState();
  }

  Future<void> setTechnicianAndCustomerInfo() async {
    Map<String, String> userMap =
        await widget.controller.retrieveMessagingUser(context, widget.messages);
    currentID = userMap['currentID'] ?? '';
    messagePersonID = userMap['messagePersonID'] ?? '';
    messagePersonName = userMap['messagePersonName'] ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.openInbox(context, widget.messages, widget.userType,
            messagePersonID, messagePersonName, currentID);
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
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
                            widget.name != messagePersonName
                                ? 'You'
                                : widget.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 115, 115, 115)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: 14,
                  color: widget.isMessageRead
                      ? const Color.fromARGB(255, 115, 115, 115)
                      : const Color.fromARGB(255, 171, 19, 75)),
            ),
          ],
        ),
      ),
    );
  }
}
