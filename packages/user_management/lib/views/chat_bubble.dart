import 'package:flutter/material.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/messaging_inbox_screen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({Key? key, required this.message, required this.type})
      : super(key: key);
  final Message message;
  final MessageType type;

  @override
  StateMVC<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends StateMVC<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Align(
        alignment: (widget.type == MessageType.receiver
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: (widget.type == MessageType.receiver
                ? Colors.white
                : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Text(widget.message.messageText!),
        ),
      ),
    );
  }
}
