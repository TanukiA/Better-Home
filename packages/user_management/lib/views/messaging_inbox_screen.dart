import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:user_management/controllers/messaging_controller.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/chat_bubble.dart';
import 'package:user_management/views/messaging_list_screen.dart';

enum MessageType {
  sender,
  receiver,
}

class MessagingInboxScreen extends StatefulWidget {
  const MessagingInboxScreen({
    Key? key,
    required this.controller,
    required this.messages,
    required this.messagePersonName,
    required this.messagePersonID,
    required this.userType,
    required this.currentID,
  }) : super(key: key);
  final MessagingController controller;
  final List<Message> messages;
  final String messagePersonID;
  final String messagePersonName;
  final String userType;
  final String currentID;

  @override
  StateMVC<MessagingInboxScreen> createState() => _MessagingInboxScreenState();
}

class _MessagingInboxScreenState extends StateMVC<MessagingInboxScreen> {
  final TextEditingController _messageController = TextEditingController();

  void addMessageToConversation(Message message) {
    setState(() {
      widget.messages.add(message);
    });
  }

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.messagePersonName,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MessagingListScreen(
                  controller: MessagingController(),
                  userType: widget.userType,
                ),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: widget.messages.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              final messageType = message.senderID == widget.messagePersonID
                  ? MessageType.receiver
                  : MessageType.sender;

              // Check if the current message is the first one of the day
              bool isFirstMessageOfDay = false;
              if (index == 0) {
                isFirstMessageOfDay = true;
              } else {
                final previousMessage = widget.messages[index - 1];
                final currentDate =
                    widget.controller.formatToLocalDate(message.dateTime!);
                final previousDate = widget.controller
                    .formatToLocalDate(previousMessage.dateTime!);
                isFirstMessageOfDay = currentDate != previousDate;
              }

              // Check if the previous message exists and has a different date
              bool isPreviousDateDifferent = false;
              if (index > 0) {
                final previousMessage = widget.messages[index - 1];
                final currentDate =
                    widget.controller.formatToLocalDate(message.dateTime!);
                final previousDate = widget.controller
                    .formatToLocalDate(previousMessage.dateTime!);
                isPreviousDateDifferent = currentDate != previousDate;
              }

              return Column(
                children: [
                  if (isFirstMessageOfDay || isPreviousDateDifferent)
                    Center(
                      child: Text(
                        widget.controller.isDateToday(message.dateTime!)
                            ? 'Today'
                            : widget.controller
                                .formatToLocalDate(message.dateTime!),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 115, 115, 115),
                            fontSize: 16),
                      ),
                    ),
                  ChatBubble(
                    message: message,
                    type: messageType,
                  ),
                  Align(
                    alignment: messageType == MessageType.sender
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        widget.controller.formatToLocalTime(message.dateTime!),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 115, 115, 115),
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 16, bottom: 10),
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                          hintText: "Type message...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.only(right: 25, bottom: 15),
              child: FloatingActionButton(
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    widget.controller.sendMessage(
                        context,
                        widget.messagePersonID,
                        widget.messagePersonName,
                        _messageController.text,
                        widget.userType);

                    addMessageToConversation(Message(
                      dateTime: DateTime.now(),
                      senderID: widget.currentID,
                      receiverID: widget.messagePersonID,
                      receiverName: widget.messagePersonName,
                      messageText: _messageController.text,
                    ));
                    _messageController.clear();
                  }
                },
                backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
                elevation: 0,
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
