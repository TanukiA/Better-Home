import 'package:authentication/models/auth_provider.dart';
import 'package:firebase_data/models/message_db.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

class Message extends ModelMVC {
  String? messageID;
  DateTime? dateTime;
  String? dateTimeStr;
  String? senderID;
  String? receiverID;
  String? senderName;
  String? receiverName;
  String? messageText;
  bool? readStatus;

  Message({
    this.messageID,
    this.dateTime,
    this.dateTimeStr,
    this.senderID,
    this.receiverID,
    this.senderName,
    this.receiverName,
    this.messageText,
    this.readStatus,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageID,
        'dateTime': dateTime?.toIso8601String(),
        'senderId': senderID,
        'receiverId': receiverID,
        'senderName': senderName,
        'receiverName': receiverName,
        'messageText': messageText,
        'readStatus': readStatus,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        messageID: json['messageId'],
        dateTime: DateTime.tryParse(json['dateTime']),
        senderID: json['senderId'],
        receiverID: json['receiverId'],
        senderName: json['senderName'],
        receiverName: json['receiverName'],
        messageText: json['messageText'],
        readStatus: json['readStatus'],
      );

  Future<List<List<Message>>> retrieveAllUserMessages(
      String userType, BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String currentID = await ap.getUserIDFromSP("session_data");
    MessageDB msgDB = MessageDB();
    List<List<Message>> allUserMessages =
        await msgDB.retrieveAllUserMessages(currentID, userType);
    return allUserMessages;
  }

  Future<List<Message>> retrieveSingleUserMessages(String messagePersonID,
      String userType, String messagePersonName, String currentID) async {
    MessageDB msgDB = MessageDB();
    List<Message> singleUserMessages;
    if (userType == "customer") {
      singleUserMessages =
          await msgDB.retrieveSingleUserMessages(currentID, messagePersonID);
    } else {
      singleUserMessages =
          await msgDB.retrieveSingleUserMessages(messagePersonID, currentID);
    }

    return singleUserMessages;
  }

  Future<void> sendNewMessage(BuildContext context, String receiverID,
      String receiverName, String messageText, String userType) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String senderID = await ap.getUserIDFromSP("session_data");
    String senderName = await ap.getUserNameFromSP("session_data");
    MessageDB msgDB = MessageDB();

    if (userType == "customer") {
      String customerID = senderID;
      String technicianID = receiverID;
      msgDB.storeNewMessage(customerID, technicianID, senderID, receiverID,
          senderName, receiverName, messageText);
    } else {
      String customerID = receiverID;
      String technicianID = senderID;
      msgDB.storeNewMessage(customerID, technicianID, senderID, receiverID,
          senderName, receiverName, messageText);
    }
  }
}
