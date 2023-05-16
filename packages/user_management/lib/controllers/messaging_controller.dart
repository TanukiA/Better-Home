import 'package:authentication/models/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:user_management/models/message.dart';
import 'package:user_management/views/messaging_inbox_screen.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
        messagePersonID, userType, currentID);

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
            fromWhere: 1,
          ),
        ),
      );
    }
  }

  Future<void> openInbox(
      BuildContext context,
      List<Message> messages,
      String userType,
      String messagePersonID,
      String messagePersonName,
      String currentID) async {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagingInboxScreen(
            controller: MessagingController(),
            messages: messages,
            messagePersonID: messagePersonID,
            messagePersonName: messagePersonName,
            userType: userType,
            currentID: currentID,
            fromWhere: 0,
          ),
        ),
      );
    }
  }

  Future<Map<String, String>> retrieveMessagingUser(
      BuildContext context, List<Message> messages) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String currentID = await ap.getUserIDFromSP("session_data");
    String messagePersonID;
    String messagePersonName;

    if (messages[0].senderID == currentID) {
      messagePersonID = messages[0].receiverID!;
      messagePersonName = messages[0].receiverName!;
    } else {
      messagePersonID = messages[0].senderID!;
      messagePersonName = messages[0].senderName!;
    }

    return {
      'currentID': currentID,
      'messagePersonID': messagePersonID,
      'messagePersonName': messagePersonName,
    };
  }

  void sendMessage(BuildContext context, String receiverID, String receiverName,
      String messageText, String userType) {
    _msg.sendNewMessage(
        context, receiverID, receiverName, messageText, userType);
  }

  bool isDateToday(DateTime date) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneDate = tz.TZDateTime.from(date, location);

    DateTime today = tz.TZDateTime.now(location);

    String formattedTimeZoneDate =
        DateFormat('dd-MM-yyyy').format(timeZoneDate);
    String formattedToday = DateFormat('dd-MM-yyyy').format(today);

    return formattedTimeZoneDate == formattedToday;
  }

  String formatToLocalDate(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneDate = tz.TZDateTime.from(dateTime, location);
    return DateFormat('dd/MM/yyyy').format(timeZoneDate);
  }

  String formatToLocalTime(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneTime = tz.TZDateTime.from(dateTime, location);
    return DateFormat('HH:mm').format(timeZoneTime);
  }

  DateTime formatToLocalDateTime(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneDateTime = tz.TZDateTime.from(dateTime, location);
    return timeZoneDateTime;
  }

  void setRead(String connectionID, BuildContext context) {
    _msg.changeReadStatus(connectionID, context);
  }
}
