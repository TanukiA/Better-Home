import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/controllers/messaging_controller.dart';
import 'package:user_management/views/messaging_inbox_screen.dart';
import 'package:user_management/models/message.dart';

class MessageUsersContainer extends StatefulWidget {
  const MessageUsersContainer(
      {Key? key,
      required this.name,
      required this.messageText,
      required this.time,
      required this.isMessageRead,
      required this.allMessages,
      required this.controller,
      required this.userType})
      : super(key: key);
  final String name;
  final String messageText;
  final String time;
  final bool isMessageRead;
  final List<List<Message>> allMessages;
  final MessagingController controller;
  final String userType;

  @override
  StateMVC<MessageUsersContainer> createState() =>
      _MessageUsersContainerState();
}

class _MessageUsersContainerState extends StateMVC<MessageUsersContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller
            .openInbox(context, widget.allMessages, widget.userType);
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
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
                  fontSize: 12,
                  color: widget.isMessageRead
                      ? Colors.pink
                      : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
