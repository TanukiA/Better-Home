import 'package:authentication/models/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/messaging_inbox_screen.dart';

class MessagingController extends ControllerMVC {
  late Message _msg;

  Message get msg => _msg;

  MessagingController() {
    _msg = Message();
  }

  Future<List<List<Message>>> retrieveAllUserMessages(
      String userType, BuildContext context) async {
    List<List<Message>> allMessages =
        await _msg.retrieveAllUserMessages(userType, context);
    return allMessages;
  }

  Future<void> messageBtnTapped(BuildContext context, String messagePersonID,
      String userType, String messagePersonName) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String currentID = await ap.getUserIDFromSP("session_data");
    List<Message> singleUserMessages = await _msg.retrieveSingleUserMessages(
        messagePersonID, userType, messagePersonName, currentID);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagingInboxScreen(
            controller: MessagingController(),
            messages: singleUserMessages,
            messagePersonID: messagePersonID,
            messagePersonName: messagePersonName,
            userType: userType,
            currentID: currentID,
          ),
        ),
      );
    }
  }

  void openInbox(
      BuildContext context, List<List<Message>> allMessages, String userType) {
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MessagingInboxScreen(),
      ),
    );
    */
  }

  void sendMessage(BuildContext context, String receiverID, String receiverName,
      String messageText, String userType) {
    _msg.sendNewMessage(
        context, receiverID, receiverName, messageText, userType);
  }
}
