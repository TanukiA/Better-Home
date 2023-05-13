import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:user_management/controllers/messaging_controller.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/chat_bubble.dart';

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
        leading: const BackButton(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(
          size: 40,
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

              return ChatBubble(
                message: message,
                type: messageType,
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
                  widget.controller.sendMessage(
                      context,
                      widget.messagePersonID,
                      widget.messagePersonName,
                      _messageController.text,
                      widget.userType);

                  addMessageToConversation(Message(
                    dateTimeStr: DateTime.now().toIso8601String(),
                    senderID: widget.currentID,
                    receiverID: widget.messagePersonID,
                    receiverName: widget.messagePersonName,
                    messageText: _messageController.text,
                  ));
                  _messageController.clear();
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
